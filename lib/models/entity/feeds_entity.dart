import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feeds_entity.g.dart';

@Entity(tableName: 'feeds')
@JsonSerializable()
class FeedsEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String url;
  final String author;
  final String published;
  final String content;
  final int catalogId;
  final int rssId;
  // status: 阅读状态 0 表示未读、1 表示已读
  final int status;

  FeedsEntity(this.id, this.title, this.url, this.author, this.published,
      this.content, this.catalogId, this.rssId, this.status);

  factory FeedsEntity.fromJson(Map<String, dynamic> json) => _$FeedsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FeedsEntityToJson(this);

  @override
  bool operator ==(o) =>
      o is FeedsEntity &&
      o.url == url &&
      o.rssId == rssId &&
      o.catalogId == catalogId &&
      o.title == title;

  @override
  int get hashCode => id.hashCode ^ url.hashCode;
}
