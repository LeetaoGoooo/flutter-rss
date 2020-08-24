
import 'package:floor/floor.dart';

@DatabaseView(
'''SELECT b.catalogId AS catalogId,a.id AS rssId,a.type AS rssType,a.url AS rssUrl, a.title AS rssTitle FROM rss2catalog b INNER JOIN rss a ON a.id == b.rssId'''
,viewName: 'multi_rss')
class MultiRssEntity {
  final int catalogId;
  final int rssId;
  final String rssType;
  final String rssUrl;
  final String rssTitle;

  MultiRssEntity(this.catalogId, this.rssId, this.rssType, this.rssUrl, this.rssTitle);
}