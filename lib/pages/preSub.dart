// 预订阅页面
import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/pages/rssCatalog.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class PreSubPage extends StatefulWidget {
  final String title;
  final String feedsUrl;
  final String type;

  PreSubPage({this.title, this.feedsUrl, this.type});

  @override
  _PreSubStatefulWidgetState createState() =>
      _PreSubStatefulWidgetState(title, feedsUrl, type);
}

class _PreSubStatefulWidgetState extends State<PreSubPage> {
  final String title;
  final String feedsUrl;
  final String type;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _waits = 3;

  _PreSubStatefulWidgetState(this.title, this.feedsUrl, this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'Subscribe',
            onPressed: () async {
              //
              await _subRss();
            },
          )
        ],
      ),
      body: new Center(
        child: new Column(children: <Widget>[
          Card(
            child: ListTile(
                // leading: FlutterLogo(size: 56.0),
                title: Text(title),
                subtitle: Text(feedsUrl)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          ),
          SizedBox(
              width: double.infinity,
              child: FlatButton(
                  // color: Colors.white,
                  // textColor: Colors.blue,
                  onPressed: () {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(builder: (_) {
                      return new RssCatalogPage(
                          title: title, type: type, feedsUrl: feedsUrl);
                    }));
                  },
                  child: Text("Add to Folder..."))),
          SizedBox(
              width: double.infinity,
              child: FlatButton(
                  // color: Colors.white,
                  // textColor: Colors.bl ue,
                  onPressed: () async {
                    await _subRss();
                  },
                  child: Text("Subscribe")))
        ]),
      ),
    );
  }

  @transaction
  Future<List<int>> _insertRss2DB() async {
    RssEntity rssEntity = new RssEntity(null, title, feedsUrl, type);
    List<Rss2CatalogEntity> rss2CatalogEntities = [];

    // 新增当前 rss 源
    var rssId = await rssDao.insertRss(rssEntity);

    Rss2CatalogEntity defaultEntity = new Rss2CatalogEntity(null, -1, rssId);
    rss2CatalogEntities.add(defaultEntity);

    return rss2catalogDao.insertRss2CatalogList(rss2CatalogEntities);
  }

  Future<void> _subRss() {
    _insertRss2DB().then((List<int> valueList) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Add Rss Successfully,will Go to Home in ${_waits} s'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'Go',
            onPressed: () {
              Navigator.of(context)
                  .pushNamed("/")
                  .then((value) => {setState(() {})});
              // Navigator.popUntil(context, ModalRoute.withName('/'));
            }),
      ));
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (_waits == 0) {
          timer.cancel();
          Navigator.of(context)
              .pushNamed("/")
              .then((value) => {setState(() {})});
          // Navigator.popUntil(context, ModalRoute.withName('/'));
        }
        setState(() {
          _waits = _waits - 1;
        });
      });
    }).catchError((error) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Add Rss Failed!'),
        behavior: SnackBarBehavior.floating,
      ));
    });
  }
}
