import 'package:floor/floor.dart';
import 'package:rss/models/entity/feeds_entity.dart';

@Entity(tableName: 'marked', foreignKeys: [
  ForeignKey(
      childColumns: ['catalogId'],
      parentColumns: ['feedId'],
      entity: FeedsEntity)
])
class MarkedEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int feedId;

  MarkedEntity(this.id, this.feedId);
}
