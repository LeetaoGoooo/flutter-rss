import 'package:floor/floor.dart';

@Entity(tableName: 'catalogs')
class CatalogEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ColumnInfo(name:'catalog',nullable: false)
  final String catalog;

  CatalogEntity(this.id, this.catalog);

  @override
  bool operator ==(o)  => o is CatalogEntity && o.id == id && o.catalog == catalog;

  @override
  int get hashCode => id.hashCode^catalog.hashCode;

}