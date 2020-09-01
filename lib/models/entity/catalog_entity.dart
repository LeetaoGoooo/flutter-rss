import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'catalog_entity.g.dart';

@Entity(tableName: 'catalogs')
@JsonSerializable()
class CatalogEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ColumnInfo(name: 'catalog', nullable: false)
  final String catalog;

  CatalogEntity(this.id, this.catalog);

  factory CatalogEntity.fromJson(Map<String, dynamic> json) =>
      _$CatalogEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CatalogEntityToJson(this);

  @override
  bool operator ==(o) =>
      o is CatalogEntity && o.id == id && o.catalog == catalog;

  @override
  int get hashCode => id.hashCode ^ catalog.hashCode;
}
