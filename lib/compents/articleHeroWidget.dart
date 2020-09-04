/// file        : articleHeroWidget.dart
/// descrption  :
/// date        : 2020/09/04 16:57:16
/// author      : Leetao

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

class ArticleHeroWidget extends StatefulWidget {
  final String link;
  final String title;
  final String pubDate;
  final String content;
  final String author;
  final VoidCallback onTap;

  const ArticleHeroWidget(
      {Key key,
      this.link,
      this.title,
      this.pubDate,
      this.content,
      this.author,
      this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ArticleHeroWidgetState(link, title, pubDate, content, author, onTap);
  }
}

class ArticleHeroWidgetState extends State<ArticleHeroWidget> {
  final String link;
  final String title;
  final String pubDate;
  String content;
  final String author;
  final VoidCallback onTap;
  final client = http.Client();

  FontSize defaultFontSize = FontSize(14);
  double defaultFontSizeValue = 14;
  Color _doneColor = Colors.white;
  Color _bookmarkColor = Colors.white;

  ArticleHeroWidgetState(this.link, this.title, this.pubDate, this.content,
      this.author, this.onTap);

  @override
  void initState() {
    super.initState();
    loadContent();
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
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.white,
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
        color: Colors.purple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                icon: Icon(
                  Icons.done,
                  color: _doneColor,
                ),
                onPressed: () {
                  setState(() {
                    _doneColor = _doneColor == Colors.white
                        ? Colors.yellow
                        : Colors.white;
                  });
                }),
            IconButton(
                icon: Icon(
                  Icons.bookmark,
                  color: _bookmarkColor,
                ),
                onPressed: () {
                  setState(() {
                    _bookmarkColor = _bookmarkColor == Colors.white
                        ? Colors.yellow
                        : Colors.white;
                  });
                }),
            IconButton(
                icon: Icon(
                  Icons.zoom_in,
                  color: Colors.white,
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
                  color: Colors.white,
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
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
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
}
