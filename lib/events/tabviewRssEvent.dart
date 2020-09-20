
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';

class TabViewRssEvent{
  CatalogEntity catalog;
  RssEntity rss;
  List<RssEntity> rssList;
  TabViewRssEvent(this.catalog,{this.rss,this.rssList});
}