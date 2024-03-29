import 'package:floor/floor.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/models/entity/rss_entity.dart';

@dao
abstract class RssDao {

  @Query('SELECT * FROM rss')
  Future<List<RssEntity>> findAllRss();

  @Query('SELECT * FROM rss WHERE id = :id')
  Future<RssEntity> findRssById(int id);

  @Query("SELECT * FROM rss WHERE url = :url")
  Future<RssEntity> findRssByUrl(String url);

  @Query('SELECT * from multi_rss WHERE catalogId = :catalogId')
  Future<List<MultiRssEntity>> findMultiRssByCatalogId(int catalogId);

  @Query('SELECT * from multi_rss')
  Future<List<MultiRssEntity>> findAllMultiRss();

  @Query('SELECT * from multi_rss WHERE rssId = :rssId')
  Future<List<MultiRssEntity>> findMultiRssByRssId(int rssId);

  @update
  Future<int> updateRss(RssEntity rssEntity);

  @insert
  Future<int> insertRss(RssEntity rssEntity);

  @insert
  Future<List<int>> insertRssList(List<RssEntity> rssEntityList);

  @delete
  Future<void> deleteRss(RssEntity rssEntity);

  @delete
  Future<void> deleteRssList(List<RssEntity> rssEntities);
}