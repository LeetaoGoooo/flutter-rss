import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/tools/feedParser.dart';
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/webfeed.dart';

class FeedNotifier extends ChangeNotifier {
  final FeedsDao feedsDao = g.feedsDao;
  final RssDao rssDao = g.rssDao;
  List<FeedsEntity> _feedList = [];
  UnmodifiableListView<FeedsEntity> get feedList =>
      UnmodifiableListView(_feedList);

  Future<List<FeedsEntity>> _getFeeds(CatalogEntity catalog) async {
    List<MultiRssEntity> multiRssList =
        await rssDao.findMultiRssByCatalogId(catalog.id);
    for (MultiRssEntity multiRssEntity in multiRssList) {
      return _buildFeeds(multiRssEntity);
    }
  }

  Future<List<FeedsEntity>> _buildFeeds(MultiRssEntity multiRssEntity) {
    if (multiRssEntity.rssType == 'rss') {
      return _buildFeedByRss(multiRssEntity);
    }
    return _buildFeedByAtom(multiRssEntity);
  }

  Future<List<FeedsEntity>> _buildFeedByAtom(
      MultiRssEntity multiRssEntity) async {
    List<FeedsEntity> feedList = [];
    FeedParser feedParser = new FeedParser(url: multiRssEntity.rssUrl);

    AtomFeed _atomFeed = await feedParser.parseAtom();
    var _author = _atomFeed.title;
    _atomFeed.items.forEach((atomItem) async {
      var _content = atomItem.content;
      var _title = atomItem.title;
      var _pubDate = atomItem.updated;
      var _link = atomItem.links[0].href;
      FeedsEntity newFeed = new FeedsEntity(null, _title, _link, _author,
          _pubDate, _content, multiRssEntity.catalogId, multiRssEntity.rssId);
      await addFeed(newFeed);
      feedList.add(newFeed);
    });
    return feedList;
  }

  Future<List<FeedsEntity>> _buildFeedByRss(
      MultiRssEntity multiRssEntity) async {
    List<FeedsEntity> feedList = [];
    FeedParser feedParser = new FeedParser(url: multiRssEntity.rssUrl);

    RssFeed _rssFeed = await feedParser.parseRss();
    var _author = _rssFeed.title;
    _rssFeed.items.forEach((rssItem) async {
      String content =
          rssItem.content != null ? rssItem.content.value : rssItem.description;
      var _title = rssItem.title;
      var _pubDate = rssItem.pubDate;
      var _link = rssItem.link;
      var _content = content;

      FeedsEntity newFeed = new FeedsEntity(null, _title, _link, _author,
          _pubDate, _content, multiRssEntity.catalogId, multiRssEntity.rssId);
      await addFeed(newFeed);
      feedList.add(newFeed);
    });
    return feedList;
  }

  Future<void> addFeed(FeedsEntity feedsEntity) async {
    await feedsDao.insertFeeds(feedsEntity).then((value) {
      _feedList.add(feedsEntity);
      notifyListeners();
    });
  }

  Future<void> addFeedList(List<FeedsEntity> feedList) async {
    await feedsDao.insertFeedList(feedList).then((value) {
      _feedList += feedList;
      notifyListeners();
    });
  }
}
