/// file        : tabService.dart
/// descrption  :
/// date        : 2020/09/04 12:40:58
/// author      : Leetao

import 'package:rss/events/tabviewRssEvent.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/service/rssService.dart';
import 'package:rss/tools/globalEventBus.dart';

class TabService {
  final RssService rssService = new RssService();
  final FeedService feedService = new FeedService();
  final GlobalEventBus eventBus = new GlobalEventBus();


  getTabs(CatalogEntity catalog,
      {RssEntity rssEntity, bool selected, int status}) async {
    List<RssEntity> rss = await rssService.getRssList(catalog);
    eventBus.event.fire(TabViewRssEvent(catalog,rssList: rss));
    print("rss length:${rss.length}");
    if (rssEntity == null) {
      await feedService.getFeeds(catalog,status:status);
    } else {
      await feedService.selectRss(catalog, rssEntity, selected,status:status);
    }
  }

  Future<void> getFavorites(CatalogEntity catalog, {int rssId}) async {
    int catalogId = catalog.id;
    if (catalogId == -1 && rssId == null) {
      await feedService.getAllFavorites();
    }
    if (catalogId != -1 && rssId == null) {
      await feedService.getFavoritesByCatalogId(catalogId);
    }
    if (rssId != null) {
       await feedService.getFavoritesByRssId(rssId);
    }
  }

  Future<void> makeFeedsRead(CatalogEntity catalog,
      {RssEntity rssEntity, bool selected, int rssId}) async {
    List<RssEntity> rssList = await rssService.getRssList(catalog);
    await feedService.makeFeedsRead(rssList);
  }
}
