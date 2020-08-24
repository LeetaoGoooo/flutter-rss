import 'package:floor/floor.dart';

@Entity(tableName: 'rss')
class RssEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String url;
  final String type;
  
  RssEntity(this.id,this.title,this.url,this.type);
}