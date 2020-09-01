import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rss_entities.g.dart';

@DatabaseView(
    '''SELECT b.catalogId AS catalogId,a.id AS rssId,a.type AS rssType,a.url AS rssUrl, a.title AS rssTitle FROM rss2catalog b INNER JOIN rss a ON a.id == b.rssId''',
    viewName: 'multi_rss')
@JsonSerializable()
class MultiRssEntity {
  final int catalogId;
  final int rssId;
  final String rssType;
  final String rssUrl;
  final String rssTitle;

  MultiRssEntity(
      this.catalogId, this.rssId, this.rssType, this.rssUrl, this.rssTitle);

  factory MultiRssEntity.fromJson(Map<String, dynamic> json) => _$MultiRssEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MultiRssEntityToJson(this);
  
}
