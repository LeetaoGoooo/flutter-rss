import 'package:floor/floor.dart';
import 'package:rss/models/entity/feeds_entity.dart';

@dao
abstract class FeedsDao {
  @Query('SELECT * FROM feeds ORDER BY published DESC')
  Future<List<FeedsEntity>> findAllFeeds();

  @Query('SELECT * FROM feeds WHERE catalogId = :catalogId')
  Future<List<FeedsEntity>> findFeedsByCatalogId(int catalogId);

  @Query('SELECT * FROM feeds WHERE rssId = :rssId')
  Future<List<FeedsEntity>> findFeedsByrssId(int rssId);

  @delete
  Future<void> deleteFeeds(FeedsEntity feedsEntity);

  @insert
  Future<int> insertFeeds(FeedsEntity feedsEntity);

  @insert
  Future<List<int>> insertFeedList(List<FeedsEntity> feedList);
}
