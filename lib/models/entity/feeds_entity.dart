import 'package:floor/floor.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';


@Entity(tableName: 'feeds', foreignKeys: [
  ForeignKey(
      childColumns: ['catalogId'],
      parentColumns: ['id'],
      entity: CatalogEntity),
  ForeignKey(childColumns: ['rssId'], parentColumns: ['id'], entity: RssEntity)
])
class FeedsEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String url;
  final String author;
  final DateTime published;
  final String content;
  final String catalogId;
  final String rssId;

  FeedsEntity(this.id, this.title, this.url, this.author, this.published,
      this.content, this.catalogId, this.rssId);
}
