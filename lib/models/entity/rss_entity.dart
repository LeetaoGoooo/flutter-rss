import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rss_entity.g.dart';

@Entity(tableName: 'rss')
@JsonSerializable()
class RssEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String url;
  final String type;

  RssEntity(this.id, this.title, this.url, this.type);

  factory RssEntity.fromJson(Map<String, dynamic> json) =>
      _$RssEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RssEntityToJson(this);
}
