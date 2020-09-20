
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';

class TabViewFeedEvent{
  CatalogEntity catalog;
  FeedsEntity feed;
  List<FeedsEntity> feeds;
  String action; // 操作类型
  TabViewFeedEvent(this.catalog,{this.feed,this.feeds,this.action});
}