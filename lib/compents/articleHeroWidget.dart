/// file        : articleHeroWidget.dart
/// descrption  :
/// date        : 2020/09/04 16:57:16
/// author      : Leetao

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/dao/feeds_dao.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/tools/feedTool.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

class ArticleHeroWidget extends StatefulWidget {
  final String link;
  final String title;
  final String pubDate;
  final String content;
  final String author;
  final VoidCallback onTap;
  final int rssId;
  final int catalogId;

  const ArticleHeroWidget(
      {Key key,
      this.link,
      this.title,
      this.pubDate,
      this.content,
      this.author,
      this.onTap,
      this.rssId,
      this.catalogId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ArticleHeroWidgetState(
        link, title, pubDate, content, author, rssId, catalogId, onTap);
  }
}

class ArticleHeroWidgetState extends State<ArticleHeroWidget> {
  final String link;
  final String title;
  final String pubDate;
  final int rssId;
  final int catalogId;
  final FeedTool feedTool = new FeedTool();
  String content;
  final String author;
  final VoidCallback onTap;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final client = http.Client();
  final FeedService feedService = new FeedService();
  int _feedId;
  final FeedsDao feedsDao = g.feedsDao;
  FontSize defaultFontSize = FontSize(14);
  double defaultFontSizeValue = 14;
  IconData bookmark = Icons.bookmark_border;

  ArticleHeroWidgetState(
    this.link,
    this.title,
    this.pubDate,
    this.content,
    this.author,
    this.rssId,
    this.catalogId,
    this.onTap,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadContent();
    _isMarked();
  }

  loadContent() async {
    if (content == null) {
      var response = await client.get(link);
      setState(() {
        content = response.body;
      });
    }
    await feedTool.makeFeedRead(new FeedsEntity(
        null, title, link, author, pubDate, content, catalogId, rssId, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              // color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            }),
        actions: [
          IconButton(
              icon: Icon(
                Icons.share,
                // color: Colors.white,
              ),
              onPressed: () {
                final RenderBox box = context.findRenderObject();
                Share.share(link,
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
              }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                icon: Icon(
                  bookmark,
                  // color: Theme.of(context).appBarTheme.iconTheme.color,
                ),
                onPressed: () async {
                  await _markBookMark();
                }),
            IconButton(
              icon: Icon(
                Icons.arrow_upward,
                // color: Theme.of(context).appBarTheme.iconTheme.color,
              ),
              onPressed: () async {
                await _getFeed(-1);
              },
            ),
            IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  // color: Theme.of(context).appBarTheme.iconTheme.color,
                ),
                onPressed: () async {
                  await _getFeed(1);
                }),
            IconButton(
                icon: Icon(
                  Icons.zoom_in,
                  // color: Theme.of(context).appBarTheme.iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    defaultFontSizeValue += 1;
                    defaultFontSize = FontSize(defaultFontSizeValue);
                  });
                }),
            IconButton(
                icon: Icon(
                  Icons.zoom_out,
                  // color: Theme.of(context).appBarTheme.iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    defaultFontSizeValue -= 1;
                    defaultFontSize = FontSize(defaultFontSizeValue);
                  });
                })
          ],
        ),
      ),
      body: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: SizedBox(
            child: Hero(
                tag: link,
                child: Material(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        alignment: Alignment.topCenter,
                      ),
                      Text(
                        '$author  $pubDate',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.subtitle2.color),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Html(
                            data: content == null ? "" : content,
                            style: {"body": Style(fontSize: defaultFontSize)}),
                      ),
                    ],
                  ),
                ))),
          )),
    );
  }

  _isMarked() {
    feedsDao.findFeedsByPart(rssId, link).then((value) {
      if (value.length > 0) {
        FeedsEntity feedsEntity = value.first;
        setState(() {
          _feedId = feedsEntity.id;
          bookmark = Icons.bookmark;
        });
      }
    });
  }

  _markBookMark() {
    setState(() {
      bookmark =
          bookmark == Icons.bookmark ? Icons.bookmark_border : Icons.bookmark;
    });
    String _message = "Removed From Favorites";
    if (bookmark == Icons.bookmark) {
      _message = "Marked as favorite";
      feedService
          .addFeedToFavorite(FeedsEntity(
              null, title, link, author, pubDate, content, catalogId, rssId, 1))
          .then((value) {
        if (value <= 0) {
          setState(() {
            _feedId = value;
          });
          _message = "Marked Failed";
        }
      });
    } else {
      feedService
          .removeFeedFromFavorite(FeedsEntity(_feedId, title, link, author,
              pubDate, content, catalogId, rssId, 1))
          .catchError((error) {
        _message = "Remove Failed";
      });
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(_message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// 获取另外一阶段的feed
  /// index 为 1，则next
  /// index 为 -1，则pre
  _getFeed(int index) async {
    FeedsEntity currentFeed = FeedsEntity(
        null, title, link, author, pubDate, content, catalogId, rssId, 1);
    FeedsEntity findFeed = await feedService.getCertainFeed(currentFeed, index);
    if (findFeed == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No feed was found"),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ArticleHeroWidget(
            content: findFeed.content,
            link: findFeed.url,
            author: findFeed.author,
            pubDate: findFeed.published,
            title: findFeed.title,
            rssId: findFeed.rssId,
            catalogId: findFeed.catalogId);
      }));
    }
  }
}
