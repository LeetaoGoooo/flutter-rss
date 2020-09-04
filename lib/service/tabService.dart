import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/models/entity/tab_entity.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/service/rssService.dart';

/// file        : tabService.dart
/// descrption  : 
/// date        : 2020/09/04 12:40:58
/// author      : Leetao

class TabService {
  final RssService rssService = new RssService();
  final FeedService feedService = new FeedService();

  Future<TabEntity> getTabs(CatalogEntity catalog,{RssEntity rssEntity,bool selected}) async {
    List<FeedsEntity> feeds = [];
    List<RssEntity> rss = await rssService.getRssList(catalog);
    print("rss length:${rss.length}");
    if(rssEntity == null && selected == null) {
       feeds = await feedService.getFeeds(catalog);
    } else {
      feeds = await feedService.selectRss(catalog, rssEntity, selected);
    }
    return TabEntity(rss, feeds);
  }
}