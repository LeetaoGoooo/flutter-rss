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
  Color _bookmarkColor;

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
    setState(() {
      _bookmarkColor = Theme.of(context).iconTheme.color;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
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
        color: Theme.of(context).bottomAppBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                icon: Icon(
                  Icons.bookmark,
                  color: _bookmarkColor,
                ),
                onPressed: () async {
                  await _markBookMark();
                }),
            IconButton(
                icon: Icon(
                  Icons.zoom_in,
                  // color: Colors.white,
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
                  // color: Colors.white,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_downward),
        onPressed: () {},
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
          _bookmarkColor = Theme.of(context).accentColor;
        });
      }
    });
  }

  _markBookMark() {
    setState(() {
      _bookmarkColor = _bookmarkColor == Theme.of(context).iconTheme.color
          ? Theme.of(context).accentColor
          : Theme.of(context).iconTheme.color;
    });
    String _message = "Removed From Favorites";
    if (_bookmarkColor == Theme.of(context).accentColor) {
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
}
