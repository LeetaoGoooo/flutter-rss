import 'package:floor/floor.dart';

@Entity(tableName: 'catalogs')
class CatalogEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ColumnInfo(name:'catalog',nullable: false)
  final String catalog;

  CatalogEntity(this.id, this.catalog);  
}