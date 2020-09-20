/// file        : tabService.dart
/// descrption  :
/// date        : 2020/09/04 12:10:15
/// author      : Leetao

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'package:rss/events/filterFeedEvent.dart';
import 'package:rss/events/tabviewFeedEvent.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/third/opmlparser/lib/opmlparser.dart';
import 'package:rss/tools/feedParser.dart';
import 'package:rss/tools/globalEventBus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/rss_feed.dart';

class FeedService {
  final FeedsDao feedsDao = g.feedsDao;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final CatalogDao catalogDao = g.catalogDao;
  final GlobalEventBus eventBus = new GlobalEventBus();

  CatalogEntity currentCatalog = new CatalogEntity(-1, "All");
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// 根据 catalog 获取 feeds
  /// 支持 catalog.id 为 -1 的情况
  Future<void> getFeeds(CatalogEntity catalog, {int status}) async {
    currentCatalog = catalog;
    List<FeedsEntity> feeds = [];
    if (catalog.id == -1) {
      feeds = await getLocalAllFeeds();
      if (feeds.length != 0) {
        getAllRemoteFeeds();
      } else {
        await getAllRemoteFeeds();
        feeds = await getLocalAllFeeds();
      }
    } else {
      List<MultiRssEntity> multiRssList =
          await rssDao.findMultiRssByCatalogId(catalog.id);
      for (MultiRssEntity multiRssEntity in multiRssList) {
        _buildFeeds(multiRssEntity);
      }
      feeds = await getFeedsByCatalog(catalog);
    }
    if (status != null) {
      feeds = filterFeedsByStatus(feeds, status);
    }
    eventBus.event.fire(TabViewFeedEvent(catalog, feeds: feeds));
  }

  List<FeedsEntity> filterFeedsByStatus(List<FeedsEntity> feeds, int status) {
    List<FeedsEntity> _filterFeeds = [];
    feeds.forEach((FeedsEntity element) {
      if (element.status == status) {
        _filterFeeds.add(element);
      }
    });
    return _filterFeeds;
  }

  /// 选定指定的 rss 获取 feeds
  Future<List<FeedsEntity>> selectRss(
      CatalogEntity catalog, RssEntity rssEntity, bool selected,
      {int status}) async {
    currentCatalog = catalog;
    final SharedPreferences prefs = await _prefs;
    currentCatalog = catalog;
    List<FeedsEntity> feeds = [];

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
      _tmpFeedsList.sort((a, b) => a.published.compareTo(b.published));
      feeds = _tmpFeedsList;
    } else {
      print("unselected current catalog:${catalog.catalog}");
      if (catalog.id == -1) {
        feeds = await getLocalAllFeeds();
      }
      feeds = await getFeedsByCatalog(catalog);
    }
    eventBus.event.fire(TabViewFeedEvent(catalog, feeds: feeds));
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
    List<String> _allFeedStringList = [];
    List<FeedsEntity> _allFeedList = [];
    List<RssEntity> rssList = await rssDao.findAllRss();

    for (RssEntity rss in rssList) {
      if (prefs.containsKey(rss.id.toString())) {
        _allFeedStringList += prefs.getStringList(rss.id.toString());
      }
    }

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
    List<RssEntity> rssList = await rssDao.findAllRss();
    print("rssList length:${rssList.length}");
    List<MultiRssEntity> multiRssList = await rssDao.findAllMultiRss();
    for (MultiRssEntity multiRssEntity in multiRssList) {
      RssEntity rssEntity = RssEntity(
          multiRssEntity.rssId,
          multiRssEntity.rssTitle,
          multiRssEntity.rssUrl,
          multiRssEntity.rssType);
      rssList.remove(rssEntity);
      await _buildFeeds(multiRssEntity);
    }
    print("rssList without catalog length:${rssList.length}");
    for (RssEntity rssItem in rssList) {
      MultiRssEntity multiRssEntity = new MultiRssEntity(
          -1, rssItem.id, rssItem.type, rssItem.url, rssItem.title);
      await _buildFeeds(multiRssEntity);
    }
  }

  _buildFeeds(MultiRssEntity multiRssEntity) async {
    final SharedPreferences prefs = await _prefs;
    // 判断 shared 是否存在，不存在则去更新，否则使用 shared 内容
    print("contains:${prefs.containsKey(multiRssEntity.rssId.toString())}");
    try {
      if (multiRssEntity.rssType == null) {
        try {
          await _buildFeedByRss(multiRssEntity);
        } catch (e) {
          await _buildFeedByAtom(multiRssEntity);
        }
      } else if (multiRssEntity.rssType == 'rss') {
        await _buildFeedByRss(multiRssEntity);
      } else {
        await _buildFeedByAtom(multiRssEntity);
      }
    } catch (e) {
      print("_buildFeeds" + e.toString());
    }
  }

  _buildFeedByAtom(MultiRssEntity multiRssEntity) async {
    print("_buildFeedByAtom ${multiRssEntity.rssTitle}");
    CatalogEntity catalog =
        await catalogDao.findCatalogById(multiRssEntity.catalogId);
    final SharedPreferences prefs = await _prefs;

    List<String> _rssFeedStringList =
        prefs.getStringList(multiRssEntity.rssId.toString());

    List<FeedsEntity> _rssList = [];
    if (_rssFeedStringList == null) {
      _rssFeedStringList = [];
      _rssList = [];
    } else {
      _rssFeedStringList.forEach((feedsStr) {
        Map _feedMap = jsonDecode(feedsStr);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _rssList.add(_feed);
      });
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

      if (!_rssList.contains(newFeed)) {
        _rssFeedStringList.add(jsonEncode(newFeed));
        _rssList.add(newFeed);
        eventBus.event.fire(TabViewFeedEvent(catalog, feed: newFeed));
      }
    });
    prefs.setStringList(multiRssEntity.rssId.toString(), _rssFeedStringList);
  }

  _buildFeedByRss(MultiRssEntity multiRssEntity) async {
    CatalogEntity catalog =
        await catalogDao.findCatalogById(multiRssEntity.catalogId);

    print("_buildFeedByRss ${multiRssEntity.rssTitle}");
    final SharedPreferences prefs = await _prefs;
    List<String> _rssFeedStringList =
        prefs.getStringList(multiRssEntity.rssId.toString());
    List<FeedsEntity> _rssList = [];
    if (_rssFeedStringList == null) {
      _rssFeedStringList = [];
      _rssList = [];
    } else {
      _rssFeedStringList.forEach((feedsStr) {
        Map _feedMap = jsonDecode(feedsStr);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        _rssList.add(_feed);
      });
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

      if (!_rssList.contains(newFeed)) {
        eventBus.event.fire(TabViewFeedEvent(catalog, feed: newFeed));
        _rssFeedStringList.add(jsonEncode(newFeed));
        _rssList.add(newFeed);
      }
    });
    prefs.setStringList(multiRssEntity.rssId.toString(), _rssFeedStringList);
  }

  /// 获取所有喜欢列表
  Future<void> getAllFavorites() async {
    CatalogEntity catalog = new CatalogEntity(-1, "All");
    List<FeedsEntity> feedsList = await feedsDao.findAllFeeds();
    eventBus.event.fire(
        TabViewFeedEvent(catalog, feeds: feedsList, action: g.ACTION_LIKE));
  }

  /// 获取该分类下的所有喜欢列表
  Future<void> getFavoritesByCatalogId(int catalogId) async {
    List<FeedsEntity> feedsList =
        await feedsDao.findFeedsByCatalogId(catalogId);
    CatalogEntity catalog = await catalogDao.findCatalogById(catalogId);
    eventBus.event.fire(
        TabViewFeedEvent(catalog, feeds: feedsList, action: g.ACTION_LIKE));
  }

  /// 根据 rssid 获取对应的喜欢列表
  Future<void> getFavoritesByRssId(int rssId) async {
    List<FeedsEntity> feedsList = await feedsDao.findFeedsByRssId(rssId);
    List<MultiRssEntity> multiRssList = await rssDao.findMultiRssByRssId(rssId);
    CatalogEntity catalog =
        await catalogDao.findCatalogById(multiRssList[0].catalogId);
    eventBus.event.fire(
        TabViewFeedEvent(catalog, feeds: feedsList, action: g.ACTION_LIKE));
  }

  /// 将 feed 保存到数据库中 添加到喜欢列表
  Future<int> addFeedToFavorite(FeedsEntity feedsEntity) async {
    return await feedsDao.insertFeeds(feedsEntity);
  }

  /// 将 feed 从喜欢列表中移除
  Future<void> removeFeedFromFavorite(FeedsEntity feedsEntity) async {
    return await feedsDao.deleteFeeds(feedsEntity);
  }

  /// 将指定 rssId 的列表数据标记为已读
  Future<void> makeFeedsRead(List<RssEntity> rssList) async {
    final SharedPreferences prefs = await _prefs;

    rssList.forEach((rss) {
      List<String> _feeds = [];
      List<String> _rssFeedStringList = prefs.getStringList(rss.id.toString());
      _rssFeedStringList.forEach((element) {
        Map _feedMap = jsonDecode(element);
        _feedMap["status"] = 1;
        FeedsEntity _feed = new FeedsEntity.fromJson(_feedMap);
        _feeds.add(jsonEncode(_feed));
      });
      prefs.setStringList(rss.id.toString(), _feeds);
    });
  }

  /// 获取 feeds 的阅读情况
  Future<Map<String, int>> getFeedReadStatus(String rssId) async {
    final SharedPreferences prefs = await _prefs;
    if (!prefs.containsKey(rssId)) {
      List<MultiRssEntity> multiRssEntityList =
          await rssDao.findMultiRssByRssId(int.parse(rssId));
      for (MultiRssEntity multiRssEntity in multiRssEntityList) {
        await _buildFeeds(multiRssEntity);
      }
      if (!prefs.containsKey(rssId)) {
        return {"all": 0, "read": 0, "unread": 0};
      }
    }
    List<String> _rssFeedStringList = prefs.getStringList(rssId);
    int all = _rssFeedStringList.length;
    int read = 0;
    int unread = 0;
    _rssFeedStringList.forEach((element) {
      Map _feedMap = jsonDecode(element);
      if (_feedMap['status'] == 1) {
        read += 1;
      } else {
        unread += 1;
      }
    });

    return {"all": all, "read": read, "unread": unread};
  }

  /// 取消订阅
  /// 删除 rss 表中对应的记录
  /// 删除 rss2catalog 表中对应的记录
  /// 清理 SharedPreferences 中的数据
  @transaction
  Future<void> unsubcribeRss(int rssId) async {
    RssEntity rssEntity = await rssDao.findRssById(rssId);
    Rss2CatalogEntity rss2catalogEntity =
        await rss2catalogDao.findCatalogByRssId(rssId);
    await rss2catalogDao.deleteRss2Catalog(rss2catalogEntity);
    await rssDao.deleteRss(rssEntity);
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(rssId.toString());
  }

  Future<void> parseOPML(File file) async {
    var opmlStr = await file.readAsString();
    Opml opml = Opml.parse(opmlStr);

    List<OpmlItem> opmlItemList = opml.items;

    var map = new HashMap();

    opmlItemList.forEach((element) {
      if (element.parentTitle == null) {
        if (element.xmlUrl == null) {
          map.putIfAbsent(element.title, () => List<OpmlItem>());
        } else {
          map.putIfAbsent("All", () => List<OpmlItem>());
          map["All"].add(element);
        }
      } else {
        map.putIfAbsent(element.parentTitle, () => List<OpmlItem>());
        map[element.parentTitle].add(element);
      }
    });

    var keys = map.keys;

    for (var key in keys) {
      await insertRssList(map[key], key);
    }
  }

  @transaction
  Future<void> insertRssList(List<OpmlItem> items, String catalog) async {
    List<OpmlItem> opmlItems = items;
    var opmlLen = opmlItems.length;
    List<RssEntity> rssList = [];

    for (var i = 0; i < opmlLen; i++) {
      var rssQuery = await rssDao.findRssByUrl(opmlItems[i].xmlUrl);
      if (rssQuery == null) {
        print("rss ${opmlItems[i].title} not exist");
        rssList.add(
            RssEntity(null, opmlItems[i].title, opmlItems[i].xmlUrl, null));
      }
    }
    List<int> rssIdList = await rssDao.insertRssList(rssList);

    if (catalog != "All") {
      var catalogQuery = await catalogDao.findCatalogByCatalog(catalog);
      var catalogId;
      if (catalogQuery == null) {
        catalogId =
            await catalogDao.insertCatalog(CatalogEntity(null, catalog));
      } else {
        catalogId = catalogQuery.id;
      }
      print("current catalog id:$catalogId catalog:$catalog");
      List<Rss2CatalogEntity> rss2catalogList = [];
      rssIdList.forEach((rssId) {
        rss2catalogList.add(Rss2CatalogEntity(null, catalogId, rssId));
      });
      await rss2catalogDao.insertRss2CatalogList(rss2catalogList);
    }
  }

  /// 获取指定位置的 feed
  Future<FeedsEntity> getCertainFeed(FeedsEntity feed, int index) async {
    List<FeedsEntity> feeds = await getLocalAllFeeds();
    int currentIndex = feeds.indexOf(feed);
    if (currentIndex == -1) {
      return null;
    }
    int findIndex = currentIndex + index;
    if (findIndex >= 0 && findIndex < feeds.length) {
      FeedsEntity findFeed = feeds[findIndex];
      return findFeed;
    }
    return null;
  }

  Future<void> getFilterFeeds(String filter,{bool titleOnly, bool contentOnly}) async {
    List<FeedsEntity> feeds = await getLocalAllFeeds();
    print("getFilterFeeds:filter:$filter, titleOnly:$titleOnly, contentOnly:$contentOnly");
    feeds.forEach((element) { 
      if(titleOnly && contentOnly) {
        if(element.title.contains(filter) || element.content.contains(filter)) {
          print("发现数据...");
          eventBus.event.fire(FilterFeedEvent(element));
        }
      }else if(titleOnly) {
        if(element.title.contains(filter)){
          eventBus.event.fire(FilterFeedEvent(element));
        }
      } else {
        if(element.content.contains(filter)) {
          eventBus.event.fire(FilterFeedEvent(element));
        }
      }
    });
  }
}
