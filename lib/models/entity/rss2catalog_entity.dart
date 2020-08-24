import 'package:floor/floor.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';

@Entity(tableName: 'rss2catalog', foreignKeys: [
  ForeignKey(
      childColumns: ['catalogId'],
      parentColumns: ['id'],
      entity: CatalogEntity),
  ForeignKey(childColumns: ['rssId'], parentColumns: ['id'], entity: RssEntity)
])
class Rss2CatalogEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int catalogId;
  final int rssId;

  Rss2CatalogEntity(this.id, this.catalogId, this.rssId);
}
