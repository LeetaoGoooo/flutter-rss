import 'dart:convert';

import 'package:rss/models/entity/feeds_entity.dart';

/// file        : feedTool.dart
/// descrption  :
/// date        : 2020/09/04 21:55:02
/// author      : Leetao

import 'package:shared_preferences/shared_preferences.dart';

class FeedTool {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  makeFeedRead(FeedsEntity feeds) async {
    final SharedPreferences prefs = await _prefs;
    print("rssId ${feeds.rssId}");

    List<String> _rssFeedStringList =
        prefs.getStringList(feeds.rssId.toString());
    int index = -1;

    // todo 优化
    int rssLength = _rssFeedStringList.length;
    for (int i = 0; i < rssLength; i++) {
      String element = _rssFeedStringList[i];
        Map _feedMap = jsonDecode(element);
        var _feed = new FeedsEntity.fromJson(_feedMap);
        if(_feed.catalogId == feeds.catalogId && _feed.rssId == feeds.rssId && _feed.url.trim() == feeds.url.trim()) {
          index = i;
          break;
        }
    }
    _rssFeedStringList.removeAt(index);
    Map feedMap = feeds.toJson();
    feedMap.putIfAbsent("status", () => 1);
    _rssFeedStringList.insert(index, jsonEncode(feedMap));
    prefs.setStringList(feeds.rssId.toString(), _rssFeedStringList);
  }
}
