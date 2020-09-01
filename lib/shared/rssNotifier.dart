import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';

import 'package:rss/constants/globals.dart' as g;

class RssNotifer extends ChangeNotifier {
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  List<RssEntity> currentRssList = [];

  getRssEntityByCatalog(CatalogEntity catalog) async {
    print("catalog:${catalog.id}-${catalog.catalog}");
    if (catalog.id == -1) {
      currentRssList = await rssDao.findAllRss();
    } else {
      currentRssList = await _getRssByCatalog(catalog);
    }
    print("currentRssList length:${currentRssList.length}");
    notifyListeners();
  }

  Future<List<RssEntity>> _getRssByCatalog(CatalogEntity catalogEntity) async {
    List<RssEntity> rssList = [];
    await rssDao
        .findMultiRssByCatalogId(catalogEntity.id)
        .then((List<MultiRssEntity> multiRssList) {
      if (multiRssList.length == 0) {
        return rssList;
      }
      multiRssList.forEach((MultiRssEntity multiRssEntity) {
        print("multiRssList rssTitle:${multiRssEntity.rssTitle}");
        RssEntity rssItem = new RssEntity(
            multiRssEntity.rssId,
            multiRssEntity.rssTitle,
            multiRssEntity.rssUrl,
            multiRssEntity.rssType);
        rssList.add(rssItem);
      });
    });
    return rssList;
  }
}
