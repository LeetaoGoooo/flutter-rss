import 'package:json_annotation/json_annotation.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';

/// file        : tab_entity.dart
/// descrption  :
/// date        : 2020/09/04 11:22:55
/// author      : Leetao

part 'tab_entity.g.dart';

@JsonSerializable()
class TabEntity {
  final List<RssEntity> rss;
  final List<FeedsEntity> feeds;

  TabEntity(this.rss,this.feeds);

  factory TabEntity.fromJson(Map<String, dynamic> json) =>
      _$TabEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TabEntityToJson(this);
}
