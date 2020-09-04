/// file        : tabService.dart
/// descrption  :
/// date        : 2020/09/04 12:10:15
/// author      : Leetao

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/tools/feedParser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/rss_feed.dart';

class FeedService {
  final FeedsDao feedsDao = g.feedsDao;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final CatalogDao catalogDao = g.catalogDao;
  CatalogEntity currentCatalog = new CatalogEntity(-1, "All");
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// 根据 catalog 获取 feeds
  /// 支持 catalog.id 为 -1 的情况
  Future<List<FeedsEntity>> getFeeds(CatalogEntity catalog) async {
    currentCatalog = catalog;
    final SharedPreferences prefs = await _prefs;
    if (catalog.id == -1) {
      if (!prefs.containsKey("allFeeds")) {
        await getAllRemoteFeeds();
      }
      return await getLocalAllFeeds();
    } else {
      List<MultiRssEntity> multiRssList =
          await rssDao.findMultiRssByCatalogId(catalog.id);
      for (MultiRssEntity multiRssEntity in multiRssList) {
        await _buildFeeds(multiRssEntity);
      }
      return await getFeedsByCatalog(catalog);
    }
  }

  /// 选定指定的 rss 获取 feeds
  Future<List<FeedsEntity>> selectRss(
      CatalogEntity catalog, RssEntity rssEntity, bool selected) async {
    currentCatalog = catalog;
    final SharedPreferences prefs = await _prefs;
    currentCatalog = catalog;
    if (selected) {
      print("selected current catalog:${catalog.catalog}");
      List<FeedsEntity> _tmpFeedsList = [];
      List<String> _rssFeedStringList =
          prefs.getStringList(rssEntity.id.toString());
      _rssFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _tmpFeedsList.add(_feed);
      });
      _tmpFeedsList.sort((a, b) =>
          DateTime.parse(a.published).compareTo(DateTime.parse(b.published)));
      return _tmpFeedsList;
    } else {
      print("unselected current catalog:${catalog.catalog}");
      if (catalog.id == -1) {
        return await getLocalAllFeeds();
      }
      return await getFeedsByCatalog(catalog);
    }
  }

  /// 根据 catalog 获取 Feeds
  /// 仅支持数据库存在的 catalog
  Future<List<FeedsEntity>> getFeedsByCatalog(CatalogEntity catalog) async {
    List<FeedsEntity> _allFeedList = [];
    final SharedPreferences prefs = await _prefs;
    List<MultiRssEntity> multiRssList =
        await rssDao.findMultiRssByCatalogId(catalog.id);

    for (MultiRssEntity multiRssEntity in multiRssList) {
      if (!prefs.containsKey(multiRssEntity.rssId.toString())) {
        await _buildFeeds(multiRssEntity);
      }
    }
    for (MultiRssEntity multiRssEntity in multiRssList) {
      List<String> _rssFeedStringList =
          prefs.getStringList(multiRssEntity.rssId.toString());
      if (_rssFeedStringList != null) {
        _rssFeedStringList.forEach((element) {
          Map _feedMap = jsonDecode(element);
          var _feed = new FeedsEntity.fromJson(_feedMap);
          _allFeedList.add(_feed);
        });
      }
    }
    _allFeedList.sort((a, b) => b.published.compareTo(a.published));
    return _allFeedList;
  }

  /// 获取本地缓存的所有数据
  Future<List<FeedsEntity>> getLocalAllFeeds() async {
    final SharedPreferences prefs = await _prefs;
    List<String> _allFeedStringList = prefs.getStringList("allFeeds");
    List<FeedsEntity> _allFeedList = [];
    if (_allFeedStringList != null) {
      _allFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _allFeedList.add(_feed);
      });
    }
    _allFeedList.sort((a, b) => b.published.compareTo(a.published));
    return _allFeedList;
  }

  /// 从远端获取数据
  getAllRemoteFeeds() async {
    List<MultiRssEntity> multiRssList = await rssDao.findAllMultiRss();
    for (MultiRssEntity multiRssEntity in multiRssList) {
      await _buildFeeds(multiRssEntity);
    }
  }

  _buildFeeds(MultiRssEntity multiRssEntity) async {
    final SharedPreferences prefs = await _prefs;
    // 判断 shared 是否存在，不存在则去更新，否则使用 shared 内容
    if (!prefs.containsKey(multiRssEntity.rssId.toString())) {
      // 通过 status 去区分某个 feeds 是否处于过滤当中
      try {
        if (multiRssEntity.rssType == 'rss') {
          await _buildFeedByRss(multiRssEntity);
        } else {
          await _buildFeedByAtom(multiRssEntity);
        }
      } catch (e) {}
    }
  }

  _buildFeedByAtom(MultiRssEntity multiRssEntity) async {
    final SharedPreferences prefs = await _prefs;

    List<String> _rssFeedStringList =
        prefs.getStringList(multiRssEntity.rssId.toString());
    List<String> _allFeedStringList = prefs.getStringList("allFeeds");

    List<FeedsEntity> _allFeedList = [];
    if (_rssFeedStringList == null) {
      _rssFeedStringList = [];
      prefs.setBool('${multiRssEntity.rssId.toString()}-status', true);
    }

    if (_allFeedStringList != null) {
      _allFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _allFeedList.add(_feed);
      });
    } else {
      _allFeedStringList = [];
    }

    FeedParser feedParser = new FeedParser(url: multiRssEntity.rssUrl);

    AtomFeed _atomFeed = await feedParser.parseAtom();
    var _author = _atomFeed.title;
    _atomFeed.items.forEach((atomItem) {
      var _content = atomItem.content;
      var _title = atomItem.title;
      var _pubDate = atomItem.updated;
      var _link = atomItem.links[0].href;
      FeedsEntity newFeed = new FeedsEntity(
          null,
          _title,
          _link,
          _author,
          new DateFormat("y-M-d").add_jm().format(_pubDate),
          _content,
          multiRssEntity.catalogId,
          multiRssEntity.rssId,
          0);

      if (!_allFeedList.contains(newFeed)) {
        _allFeedStringList.add(jsonEncode(newFeed));
        _rssFeedStringList.add(jsonEncode(newFeed));

        prefs.setStringList(
            multiRssEntity.rssId.toString(), _rssFeedStringList);
        prefs.setStringList("allFeeds", _allFeedStringList);
      }
    });
  }

  _buildFeedByRss(MultiRssEntity multiRssEntity) async {
    final SharedPreferences prefs = await _prefs;
    List<String> _rssFeedStringList =
        prefs.getStringList(multiRssEntity.rssId.toString());
    List<String> _allFeedStringList = prefs.getStringList("allFeeds");
    List<FeedsEntity> _allFeedList = [];

    if (_rssFeedStringList == null) {
      _rssFeedStringList = [];
    }

    if (_allFeedStringList != null) {
      _allFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _allFeedList.add(_feed);
      });
    } else {
      _allFeedStringList = [];
    }

    FeedParser feedParser = new FeedParser(url: multiRssEntity.rssUrl);

    RssFeed _rssFeed = await feedParser.parseRss();
    var _author = _rssFeed.title;
    _rssFeed.items.forEach((rssItem) {
      String content =
          rssItem.content != null ? rssItem.content.value : rssItem.description;
      var _title = rssItem.title.replaceAll(" ", "");
      var _pubDate = rssItem.pubDate;
      var _link = rssItem.link;
      var _content = content;
      FeedsEntity newFeed = new FeedsEntity(
          null,
          _title,
          _link,
          _author,
          new DateFormat("y-M-d").add_jm().format(_pubDate),
          _content,
          multiRssEntity.catalogId,
          multiRssEntity.rssId,
          0);

      if (!_allFeedList.contains(newFeed)) {
        _allFeedStringList.add(jsonEncode(newFeed));
        _rssFeedStringList.add(jsonEncode(newFeed));
        prefs.setStringList(
            multiRssEntity.rssId.toString(), _rssFeedStringList);
        prefs.setStringList("allFeeds", _allFeedStringList);
      }
    });
  }
}
