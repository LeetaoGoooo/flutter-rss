
import 'package:rss/models/entity/feeds_entity.dart';

class TabViewFeedEvent{
  FeedsEntity feed;
  List<FeedsEntity> feeds;
  String action; // 操作类型
  TabViewFeedEvent({this.feed,this.feeds,this.action});
}