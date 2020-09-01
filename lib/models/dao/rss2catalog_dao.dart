import 'package:floor/floor.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';


@dao
abstract class Rss2CatalogDao {
  @Query('SELECT * FROM rss2catalog')
  Future<List<Rss2CatalogEntity>> findAllRss2Catalogs();

  @Query('SELECT * FROM rss2catalog WHERE catalogId = :catalogId')
  Future<List<Rss2CatalogEntity>> findRssByCatalogId(int catalogId);


  @Query('SELECT * FROM rss2catalog WHERE rssId = :rssId')
  Future<Rss2CatalogEntity> findCatalogByRssId(int rssId);

  @insert
  Future<List<int>> insertRss2CatalogList(List<Rss2CatalogEntity> rss2CatalogEntityList);

  @insert
  Future<int> insertRss2Catalog(Rss2CatalogEntity rss2CatalogEntityList);

  @delete
  Future<void> deleteRss2Catalog(Rss2CatalogEntity rss2CatalogEntity);
}