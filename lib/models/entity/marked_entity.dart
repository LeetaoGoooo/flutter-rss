import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rss/models/entity/feeds_entity.dart';

part 'marked_entity.g.dart';

@Entity(tableName: 'marked', foreignKeys: [
  ForeignKey(
      childColumns: ['catalogId'],
      parentColumns: ['feedId'],
      entity: FeedsEntity)
])
@JsonSerializable()
class MarkedEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int feedId;

  MarkedEntity(this.id, this.feedId);

  factory MarkedEntity.fromJson(Map<String, dynamic> json) => _$MarkedEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MarkedEntityToJson(this);
  
}
