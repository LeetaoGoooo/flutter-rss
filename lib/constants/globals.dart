var catalogDao;
var rssDao;
var rss2catalogDao;
var feedsDao;

final int FEED_READ = 1;
final int FEED_UNREAD = 0;
final int WAITS = 3;

final String ACTION_LIKE="ACTION_LIKE"; // 获取喜欢的列表
final String ACTION_ALL="ACTION_ALL"; // 获取所有的列表
final String ACTION_UNREAD = "ACTION_UNREAD"; // 获取所有的未读列表