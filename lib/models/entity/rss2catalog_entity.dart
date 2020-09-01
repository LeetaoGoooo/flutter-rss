import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';

part 'rss2catalog_entity.g.dart';

@Entity(tableName: 'rss2catalog', foreignKeys: [
  ForeignKey(
      childColumns: ['catalogId'],
      parentColumns: ['id'],
      entity: CatalogEntity),
  ForeignKey(childColumns: ['rssId'], parentColumns: ['id'], entity: RssEntity)
])
@JsonSerializable()
class Rss2CatalogEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int catalogId;
  final int rssId;

  Rss2CatalogEntity(this.id, this.catalogId, this.rssId);

  factory Rss2CatalogEntity.fromJson(Map<String, dynamic> json) =>
      _$Rss2CatalogEntityFromJson(json);

  Map<String, dynamic> toJson() => _$Rss2CatalogEntityToJson(this);
}
