import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:rss/compents/rssFeedWidget.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/shared/feedNotifier.dart';
import 'package:tuple/tuple.dart';

class TabViewWidget extends StatefulWidget {
  final CatalogEntity catalog;
  const TabViewWidget({Key key, this.catalog}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabViewWidgetState(catalog);
  }
}

class TabViewWidgetState extends State<TabViewWidget> {
  final CatalogEntity catalog;
  TabViewWidgetState(this.catalog);

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Selector<FeedNotifier, Tuple2<CatalogEntity, List<FeedsEntity>>>(
        selector: (_, feed) =>
            Tuple2(feed.currentCatalog, feed.currentFeedsList),
        shouldRebuild: (previous, next) {
          print("pre ${previous.item1.id},next ${next.item1.id}");
          return previous.item1.id == next.item1.id &&
              next.item2 != null &&
              next.item2.length > 0;
        },
        builder: (context, data, child) {
          var _feedsList = data.item2;
          print(
              "${data.item1.catalog} was rebuilded,curent list length:${data.item2.length}");
                return SizedBox.expand(
                    child: Container(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _feedsList.length,
                            itemBuilder: (context, index) {
                              FeedsEntity _feedsEntity =
                                  _feedsList[index];
                              String _coverUrl =
                                  _getFirstImageUrl(_feedsEntity.content);
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
        // });
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
