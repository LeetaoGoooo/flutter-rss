// 预订阅页面
import 'package:flutter/material.dart';
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

  _PreSubStatefulWidgetState(this.title, this.feedsUrl, this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'Subscribe',
            onPressed: () {
              //
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
                  color: Colors.white,
                  textColor: Colors.blue,
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
                  color: Colors.white,
                  textColor: Colors.blue,
                  onPressed: () {},
                  child: Text("Subscribe")))
        ]),
      ),
    );
  }
}
