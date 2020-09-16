// import 'package:flutter/foundation.dart';
import 'package:rss/events/tabviewRssEvent.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/models/entity/tab_entity.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/service/rssService.dart';
import 'package:rss/tools/globalEventBus.dart';

/// file        : tabService.dart
/// descrption  :
/// date        : 2020/09/04 12:40:58
/// author      : Leetao

class TabService {
  final RssService rssService = new RssService();
  final FeedService feedService = new FeedService();
  final GlobalEventBus eventBus = new GlobalEventBus();


  getTabs(CatalogEntity catalog,
      {RssEntity rssEntity, bool selected, int status}) async {
    List<FeedsEntity> feeds = [];
    List<RssEntity> rss = await rssService.getRssList(catalog);
    eventBus.event.fire(TabViewRssEvent(rssList: rss));
    print("rss length:${rss.length}");
    if (rssEntity == null && selected == null) {
      await feedService.getFeeds(catalog);
    } else {
      await feedService.selectRss(catalog, rssEntity, selected);
    }
    if (status != null) {
      print("filter....");
      feedService.filterFeedsByStatus(feeds, status);
    }
    // return TabEntity(rss, feeds);
  }

  Future<TabEntity> getFavorites(CatalogEntity catalog, {int rssId}) async {
    List<RssEntity> rss = await rssService.getRssList(catalog);
    int catalogId = catalog.id;

    List<FeedsEntity> feeds = [];
    if (catalogId == -1 && rssId == null) {
      feeds = await feedService.getAllFavorites();
    }
    if (catalogId != -1 && rssId == null) {
      feeds = await feedService.getFavoritesByCatalogId(catalogId);
    }
    if (rssId != null) {
      feeds = await feedService.getFavoritesByRssId(rssId);
    }
    print("favorites:${feeds.length}");
    return TabEntity(rss, feeds);
  }

  Future<void> makeFeedsRead(CatalogEntity catalog,
      {RssEntity rssEntity, bool selected, int rssId}) async {
    List<RssEntity> rssList = await rssService.getRssList(catalog);
    await feedService.makeFeedsRead(rssList);
  }
}
