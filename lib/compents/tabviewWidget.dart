import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:rss/compents/rssFeedWidget.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/shared/feedNotifier.dart';

class TabViewWidget extends StatefulWidget {
  TabViewWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabViewWidgetState();
  }
}

class TabViewWidgetState extends State<TabViewWidget> {
  TabViewWidgetState();

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Consumer<FeedNotifier>(builder: (context, notifier, child) {
      var _feedsList = notifier.currentFeedsList;
      return SizedBox.expand(
          child: Container(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _feedsList.length,
                  itemBuilder: (context, index) {
                    FeedsEntity _feedsEntity = _feedsList[index];
                    String _coverUrl = _getFirstImageUrl(_feedsEntity.content);
                    var document = parse(_feedsEntity.content);
                    var _subTitle = parse(document.body.text)
                        .documentElement
                        .text
                        .replaceAll(RegExp('[\n|\s+|\s*]'), "")
                        .trim()
                        .substring(0, 30);
                    RssFeedListTile card = new RssFeedListTile(
                        catalogId: _feedsEntity.catalogId,
                        coverUrl: _coverUrl,
                        title: _feedsEntity.title.replaceAll(" ", ""),
                        subTitle: _subTitle,
                        publishDate: _feedsEntity.published,
                        author: _feedsEntity.author,
                        content: _feedsEntity.content,
                        link: _feedsEntity.url);
                    return card;
                  })));
    });
  }

  String _getFirstImageUrl(String description) {
    RegExp regExp = new RegExp(r'<img\s+src="(.+?)"');
    Iterable<Match> matches = regExp.allMatches(description);
    if (matches == null) {
      return null;
    }
    if (matches.toSet().length > 0) {
      return matches.first.group(1);
    }
    return null;
  }
}
