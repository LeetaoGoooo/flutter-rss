import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/tools/feedParser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/webfeed.dart';

class FeedNotifier extends ChangeNotifier {
  final FeedsDao feedsDao = g.feedsDao;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final CatalogDao catalogDao = g.catalogDao;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FeedsEntity> currentFeedsList = [];

  Map<int, Map> catalog2FeedList = {};

  Future<List<FeedsEntity>> getAllFeedList() async {
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
    return _allFeedList;
  }

  Future<List<FeedsEntity>> getFeedsByCatalog(CatalogEntity catalog) async {
    List<FeedsEntity> _allFeedList = [];
    final SharedPreferences prefs = await _prefs;
    List<MultiRssEntity> multiRssList =
        await rssDao.findMultiRssByCatalogId(catalog.id);
    for (MultiRssEntity multiRssEntity in multiRssList) {
      if (prefs.containsKey(multiRssEntity.rssId.toString()) &&
          prefs.getBool('${multiRssEntity.rssId.toString()}-status')) {
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
    }
    return _allFeedList;
  }

  getAllFeeds() async {
    List<MultiRssEntity> multiRssList = await rssDao.findAllMultiRss();
    for (MultiRssEntity multiRssEntity in multiRssList) {
      await _buildFeeds(multiRssEntity);
    }
  }

  selectRss(RssEntity rssEntity, bool selected) async {
    final SharedPreferences prefs = await _prefs;
    if (selected) {
      currentFeedsList = [];

      List<MultiRssEntity> multiRssList =
          await rssDao.findMultiRssByRssId(rssEntity.id);
      for (MultiRssEntity multiRssEntity in multiRssList) {
        await _buildFeeds(multiRssEntity);
      }

      List<String> _rssFeedStringList =
          prefs.getStringList(rssEntity.id.toString());
      _rssFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        currentFeedsList.add(_feed);
      });
    } else {
      Rss2CatalogEntity rss2catalogEntity =
          await rss2catalogDao.findCatalogByRssId(rssEntity.id);
      CatalogEntity catalogEntity =
          await catalogDao.findCatalogById(rss2catalogEntity.catalogId);
      await getFeeds(catalogEntity);
    }
    notifyListeners();
  }

  getFeeds(CatalogEntity catalog) async {
    final SharedPreferences prefs = await _prefs;
    if (catalog.id == -1) {
      if (!prefs.containsKey("allFeeds")) {
        await getAllFeeds();
      }
      currentFeedsList = await getAllFeedList();
    } else {
      List<MultiRssEntity> multiRssList =
          await rssDao.findMultiRssByCatalogId(catalog.id);
      for (MultiRssEntity multiRssEntity in multiRssList) {
        await _buildFeeds(multiRssEntity);
      }
      currentFeedsList = await getFeedsByCatalog(catalog);
    }
    notifyListeners();
  }

  _buildFeeds(MultiRssEntity multiRssEntity) async {
    final SharedPreferences prefs = await _prefs;
    // 判断 shared 是否存在，不存在则去更新，否则使用 shared 内容
    if (!prefs.containsKey(multiRssEntity.rssId.toString())) {
      // 通过 status 去区分某个 feeds 是否处于过滤当中
      if (multiRssEntity.rssType == 'rss') {
        await _buildFeedByRss(multiRssEntity);
      } else {
        await _buildFeedByAtom(multiRssEntity);
      }
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
