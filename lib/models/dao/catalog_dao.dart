import 'package:floor/floor.dart';
import 'package:rss/models/entity/catalog_entity.dart';

@dao
abstract class CatalogDao {

  @Query('SELECT * FROM catalogs')
  Future<List<CatalogEntity>> findAllCatalogs();

  @Query('SELECT * FROM catalogs WHERE id = :id')
  Future<CatalogEntity> findCatalogById(int id);

  @Query('SELECT * FROM catalogs WHERE catalog = :catalog')
  Future<CatalogEntity> findCatalogByCatalog(String catalog);

  @update
  Future<int> updateCatlog(CatalogEntity catalog);

  @delete
  Future<void> deleteCatalog(CatalogEntity  catalogEntity);

  @insert
  Future<int> insertCatalog(CatalogEntity  catalogEntity);


}