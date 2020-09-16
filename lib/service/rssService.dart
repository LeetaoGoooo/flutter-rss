/// file        : rssService.dart
/// descrption  : 
/// date        : 2020/09/04 12:31:18
/// author      : Leetao

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';

import 'package:rss/constants/globals.dart' as g;

class RssService {
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  List<RssEntity> currentRssList = [];

  /// 根据 catalog 获取对应的 rssList
  Future<List<RssEntity>> getRssList(CatalogEntity catalog) async {
    if (catalog.id == -1) {
      return await rssDao.findAllRss();
    } else {
      return await _getRssByCatalog(catalog);
    }
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
        print(multiRssEntity.rssTitle);
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

  @transaction
  Future<int> updateRss(int rssId,String title,String url, int catalogId) async {
    Rss2CatalogEntity rss2catalogEntity = await rss2catalogDao.findCatalogByRssId(rssId);
    Rss2CatalogEntity rss2catalogUpdate = Rss2CatalogEntity(rss2catalogEntity.id, catalogId, rssId);
    await rss2catalogDao.updateRss2Catalog(rss2catalogUpdate);
    RssEntity rssEntity = await rssDao.findRssById(rssId);
    return await rssDao.updateRss(RssEntity(rssId,title,url,rssEntity.type));
  }
}
