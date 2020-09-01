import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import '../constants/globals.dart' as g;

/// feed 后台进程
class FeedService {
  final FeedsDao feedsDao  = g.feedsDao;

  Future<List<FeedsEntity>> _getAllFeedsFromDB() {
    return feedsDao.findAllFeeds();    
  }

  Future<List<FeedsEntity>> _getFeedsByCatalog(int catalogId) {
    return feedsDao.findFeedsByCatalogId(catalogId);
  }

  Future<List<FeedsEntity>> _getFeedsByRssId(int rssId) {
    return feedsDao.findFeedsByRssId(rssId);
  }

  Future<int> _insertFeeds(FeedsEntity feedsEntity) {
    return feedsDao.insertFeeds(feedsEntity);
  }

  Future<List<int>> _insertFeedList(List<FeedsEntity> feedList) {
    return feedsDao.insertFeedList(feedList);
  }
}