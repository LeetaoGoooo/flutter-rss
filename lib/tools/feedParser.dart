import 'package:http/http.dart' as http;
import 'package:rss/exceptions/FeedParserException.dart';
import 'package:webfeed/webfeed.dart';

class FeedParser {
  final String url;
  final client = http.Client();

  FeedParser({this.url});

  Future<RssFeed> parseRss() async {
    try {
      var response = await client.get(this.url).timeout(Duration(seconds: 5));
      var channel = RssFeed.parse(response.body);
      return channel;
    } catch (e) {
      throw new FeedParseRssException();
    }
  }

  Future<AtomFeed> parseAtom() async {
    try {
      var response = await client.get(this.url).timeout(Duration(seconds: 5));
      var feed = AtomFeed.parse(response.body);
      return feed;
    } catch (e) {
      client.close();
      throw new FeedParseAtomException();
    }
  }
}
