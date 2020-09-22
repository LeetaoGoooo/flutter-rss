/// file        : catalogService.dart
/// descrption  :
/// date        : 2020/09/18 15:10:50
/// author      : Leetao
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss/events/rssCardEvent.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rsscard_entity.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/service/feedService.dart';
import 'package:rss/tools/globalEventBus.dart';
import 'package:rss/tools/netWork.dart';

class CatalogService {
  final client = http.Client();
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  final FeedService feedService = new FeedService();
  final GlobalEventBus eventBus = new GlobalEventBus();

  getAllRssCard() async {
    print("加载rssCard...");
    List<MultiRssEntity> _multiRssList = await rssDao.findAllMultiRss();
    if(_multiRssList.length == 0){
      eventBus.event.fire(RssCardEvent(null));
    }
    for (var item in _multiRssList) {
      await _getRssCardEntity(item);
    }
  }

  Future<RssCardEntity> _getRssCardEntity(MultiRssEntity multiRssEntity) async {
    var _catalog = await catalogDao.findCatalogById(multiRssEntity.catalogId);
    var _subTitle = _catalog == null ? "All" : _catalog.catalog;
    var _avatar = await _getWebSiteIcon(multiRssEntity.rssUrl);
    var _readMap =
        await feedService.getFeedReadStatus(multiRssEntity.rssId.toString());
    RssCardEntity rssCardEntity = new RssCardEntity(
        _avatar,
        multiRssEntity.rssTitle,
        _subTitle,
        _readMap['all'],
        _readMap['read'],
        _readMap['unread'],
        multiRssEntity.rssId,
        multiRssEntity.catalogId,
        multiRssEntity.rssUrl);
    eventBus.event.fire(RssCardEvent(rssCardEntity));
  }

  Future<Widget> _getWebSiteIcon(String feedUrl) async {
    List<String> urlSplits = feedUrl.split("/");
    String domain = feedUrl.substring(
        0, feedUrl.length - urlSplits[urlSplits.length - 1].length - 1);
    String _url = await _getFaviconUrl(domain);
    var _image = Image(
      color: Colors.grey,
      image: AssetImage('assets/rss.png'),
    );
    if (_url == null) {
      return _image;
    }
    String faviconUrl = _url;
    try {
      _image = Image.network(faviconUrl);
    } catch (e) {}
    return _image;
  }

  Future<String> _getFaviconUrl(String domain) async {
    if (!await NetWorkTool.isConnected()) {
      print("当前网络未连接");
      return null;
    }
    try {
      var response = await client.get(domain).timeout(Duration(seconds: 5));
      RegExp regExp = new RegExp(r'rel="shortcut icon" href="(.+\.ico).+?"');
      Iterable<Match> matches = regExp.allMatches(response.body);
      if (matches == null) {
        return null;
      }
      if (matches.toSet().length > 0) {
        var match = matches.first.group(1);
        return match.indexOf("https://") != -1 ? match : "$domain/$match";
      }
    } catch (e) {
      return null;
    }
  }
}
