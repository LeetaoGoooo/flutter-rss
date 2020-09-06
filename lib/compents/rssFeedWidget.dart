import 'package:flutter/material.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/tools/feedTool.dart';
import 'articleHeroWidget.dart';

/*
 * 
 */
class RssFeedListTile extends StatefulWidget {
  final String tab;
  final String coverUrl;
  final String title;
  final String subTitle;
  final String publishDate;
  final String author;
  final String content;
  final String link;
  final int catalogId;
  final int status;
  final int rssId;

  const RssFeedListTile(
      {Key key,
      this.coverUrl,
      this.title,
      this.subTitle,
      this.publishDate,
      this.author,
      this.content,
      this.link, this.catalogId, this.tab, this.status, this.rssId})
      : assert(title != null),
        assert(subTitle != null),
        assert(publishDate != null),
        assert(author != null),
        // assert(content != null),
        assert(link != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RssFeedLisTileState(coverUrl, title, subTitle, publishDate, author, content, link, catalogId, tab,status,rssId);
  }
}

class RssFeedLisTileState extends State<RssFeedListTile> {
  final String coverUrl;
  final String title;
  final String subTitle;
  final String publishDate;
  final String author;
  final String content;
  final String link;
  final int catalogId;
  final int rssId;
  int status; // 判断是否点击
  final String tab;
  final FeedTool feedTool = new FeedTool();


  RssFeedLisTileState(this.coverUrl, this.title, this.subTitle,
      this.publishDate, this.author, this.content, this.link, this.catalogId, this.tab, this.status, this.rssId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          status = 1;
        });
        await feedTool.makeFeedRead(new FeedsEntity(null, title, link, author, publishDate, content, catalogId, rssId, status));
        print("status $status");
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ArticleHeroWidget(
              content: content,
              link: link,
              author: author,
              pubDate: publishDate,
              title: title,
              rssId: rssId,
              catalogId: catalogId);
        }));
      },
      child: Hero(
        tag: "$tab-$link",
        child: Card(
          elevation: 18.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: [
              _getWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      author,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Text(
                      publishDate,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWidget() {
    if (coverUrl == null || coverUrl.isEmpty) {
      return _widgetWithoutCover();
    }
    return _widgetWithCover();
  }

  Widget _widgetWithCover() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(color: status == 1 ? Colors.grey : Colors.black,fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(color: Colors.grey),
                    )
                  ]))),
          Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 16, 8),
                child: Image.network(
                  coverUrl,
                  fit: BoxFit.fill,
                  height: 80,
                  width: 80,
                ),
              ),
              flex: 1)
        ]);
  }

  Widget _widgetWithoutCover() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: TextStyle(color: status == 1 ? Colors.grey : Colors.black,fontWeight: FontWeight.bold),
                        )),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subTitle,
                          style: TextStyle(color: Colors.grey),
                        ))
                  ])))
        ]);
  }
}
