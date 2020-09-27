import 'package:flutter/material.dart';

/// file        : rsscard_entity.dart
/// descrption  :
/// date        : 2020/09/18 15:14:37
/// author      : Leetao

class RssCardEntity {
  final Widget avatar;
  final String title;
  final String subTitle;
  final int all;
  final int read;
  final int unread;
  final int rssId;
  final int catalogId;
  final String url;

  RssCardEntity(this.avatar, this.title, this.subTitle, this.all, this.read,
      this.unread, this.rssId, this.catalogId, this.url);

  @override
  bool operator ==(o) =>
      o is RssCardEntity &&
      o.rssId == rssId &&
      o.url == url;

  @override
  int get hashCode => rssId.hashCode ^ url.hashCode;

}
