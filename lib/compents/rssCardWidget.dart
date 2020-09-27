import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rss/compents/rssEditWidget.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/service/feedService.dart';

class RssCard extends StatefulWidget {
  final Widget avatar;
  final String title;
  final String subTitle;
  final int all;
  final int read;
  final int unread;
  final int rssId;
  final int catalogId;
  final String url;
  final AsyncCallback voidCallback;

  RssCard(
      {Key key,
      this.avatar,
      this.title,
      this.subTitle,
      this.all,
      this.read,
      this.unread,
      this.rssId,
      this.catalogId,
      this.voidCallback,
      this.url})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RssCardStateWidget();
}

class RssCardStateWidget extends State<RssCard> {
  final double circleRadius = 60.0;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final RssDao rssDao = g.rssDao;
  final FeedService feedService = new FeedService();

  @override
  Widget build(BuildContext context) {
    print("rssCardWidget ${widget.title}");
    return GestureDetector(
        onTap: () {},
        onLongPress: () {
          _showReadBottomSheet(context);
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          // color: Color(0xffE0E0E0),
          child: Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: circleRadius / 2.0,
                    ),

                    ///here we create space for the circle avatar to get ut of the box
                    child: Container(
                      height: 320.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0.0, 5.0),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: circleRadius / 2,
                              ),
                              Text(
                                widget.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0),
                              ),
                              Text(
                                widget.subTitle,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .color),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'ALL',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .color,
                                          ),
                                        ),
                                        Text(
                                          widget.all.toString(),
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .color),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'READED',
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .color,
                                          ),
                                        ),
                                        Text(
                                          widget.read.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          "UNREAD",
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .color,
                                          ),
                                        ),
                                        Text(
                                          widget.unread.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ),
                  ),

                  ///Image Avatar
                  Container(
                    width: circleRadius,
                    height: circleRadius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0.0, 5.0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Center(
                        child: Container(
                          child: widget.avatar,

                          /// replace your image with the Icon
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }

  void _showReadBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: Icon(Icons.done),
                title: new Text("Make All as Read"),
                onTap: () async {
                  /// 调用 ancestor 的方法
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: Icon(Icons.delete),
                title: new Text("Unsubscribe"),
                onTap: () async {
                  _unsubcribeDialog(widget.rssId);
                  Navigator.pop(context);
                },
              ),
              new ListTile(
                leading: Icon(Icons.edit),
                title: new Text("Edit"),
                onTap: () {
                  _openEditDialog();
                },
              ),
              new ListTile(
                leading: Icon(Icons.cancel),
                title: new Text("Cancle"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> _unsubcribeDialog(int rssId) async {
    RssEntity rssEntity = await rssDao.findRssById(rssId);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Unsubscrie"),
          content: Text("Will you unsubscrie ${rssEntity?.title}?"),
          actions: [
            FlatButton(
              child: Text("Yes"),
              onPressed: () async {
                await feedService.unsubcribeRss(rssId);
                await widget.voidCallback();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
                onPressed: () => {Navigator.of(context).pop()},
                child: Text("No"))
          ],
        );
      },
    );
  }

  Future _openEditDialog() async {
    Navigator.of(context).pop();
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new RssEditDialog(
              avatar: widget.avatar,
              title: widget.title,
              catalog: widget.subTitle,
              catalogId: widget.catalogId,
              rssId: widget.rssId,
              url: widget.url,
              voidCallback: widget.voidCallback);
        },
        fullscreenDialog: true));
  }
}
