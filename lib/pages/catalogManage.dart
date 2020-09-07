import 'dart:collection';

/// file        : catalogManage.dart
/// descrption  :  分类管理页面
/// date        : 2020/09/06 20:11:44
/// author      : Leetao

import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:rss/compents/rssCardWidget.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:http/http.dart' as http;
import 'package:rss/service/feedService.dart';

class CatalogManage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CatalogManageStateWidget();
}

class CatalogManageStateWidget extends State<CatalogManage> {
  final RssDao rssDao = g.rssDao;
  final FeedService feedService = new FeedService();
  final client = http.Client();
  Future<List<MultiRssEntity>> _multiRssList;
  List<Widget> _avatars = [];
  Map _rssMap = HashMap();

  @override
  void initState() {
    super.initState();
    // setState(() {
    _multiRssList = getAllMultiRssEntity();
    // });
  }

  Future<List<MultiRssEntity>> getAllMultiRssEntity() async {
    print("getAllMultiRssEntity");
    var mutiRssList = await rssDao.findAllMultiRss();
    List<String> _webSiteUrl = [];
    List<String> _rssIdList = [];
    mutiRssList.forEach((element) {
      _webSiteUrl.add(element.rssUrl);
      _rssIdList.add(element.rssId.toString());
    });
    _avatars = await _getAllWebSiteIcon(_webSiteUrl);
    _rssMap = await _getRssReadMap(_rssIdList);
    return mutiRssList;
  }

  @override
  Widget build(BuildContext context) {
    print("build...");
    return Scaffold(
      appBar: GradientAppBar(
        title: Text("CatalogManage"),
        // elevation: 0,
        backgroundColorStart: Colors.deepPurple,
        backgroundColorEnd: Colors.purple,
      ),
      body: FutureBuilder<List<MultiRssEntity>>(
        future: _multiRssList,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              child: GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    MultiRssEntity multiRssEntity = snapshot.data[index];
                    // return Card(
                    //     elevation: 18.0,
                    //     clipBehavior: Clip.antiAlias,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(15.0),
                    //     ),
                    //     child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           CircleAvatar(
                    //             backgroundColor: Colors.grey,
                    //             foregroundColor: Colors.white,
                    //             child: _avatars.isEmpty
                    //                 ? _defaultImage
                    //                 : _avatars[index],
                    //           ),
                    //           ListTile(
                    //             title:
                    //                 Center(child: Text(multiRssEntity.rssTitle)),
                    //             subtitle:
                    //                 Center(child: Text(multiRssEntity.rssTitle)),
                    //           )
                    //         ])
                    //         );
                    return RssCard(
                        avatar: _avatars[index],
                        title: multiRssEntity.rssTitle,
                        subTitle: multiRssEntity.rssTitle,
                        all: _rssMap[multiRssEntity.rssId.toString()]["all"],
                        read: _rssMap[multiRssEntity.rssId.toString()]["read"],
                        unread: _rssMap[multiRssEntity.rssId.toString()]
                            ["unread"]);
                  }),
              onRefresh: () {
                  _multiRssList = getAllMultiRssEntity();
                return _multiRssList;
              },
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Error"));
          }
          return Align(
              child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ));
        },
      ),
    );
  }

  Widget _buildCardList(data) {
    
  }

  Future<List<Widget>> _getAllWebSiteIcon(List<String> urlList) async {
    List<Widget> _widgets = [];
    for (var i = 0; i < urlList.length; i++) {
      var _widget = await _getWebSiteIcon(urlList[i]);
      _widgets.add(_widget);
    }
    return _widgets;
  }

  Future<Map> _getRssReadMap(List<String> rssIdList) async {
    int rssLen = rssIdList.length;
    var _map = HashMap();
    for (var i = 0; i < rssLen; i++) {
      _map[rssIdList[i]] = await feedService.getFeedReadStatus(rssIdList[i]);
      print(_map);
    }
    return _map;
  }

  Future<Widget> _getWebSiteIcon(String feedUrl) async {
    List<String> urlSplits = feedUrl.split("/");
    String domain = feedUrl.substring(
        0, feedUrl.length - urlSplits[urlSplits.length - 1].length - 1);
    String _url = await _getFaviconUrl(domain);
    var _image = Image(
      color: Colors.grey,
      image: AssetImage('assets/rss.png'),
    );
    if (_url == null) {
      return _image;
    }
    String faviconUrl = _url;
    try {
      _image = Image.network(faviconUrl);
    } catch (e) {}
    return _image;
  }

  Future<String> _getFaviconUrl(String domain) async {
    try {
      var response = await client.get(domain).timeout(Duration(seconds: 5));
      RegExp regExp = new RegExp(r'rel="shortcut icon" href="(.+\.ico).+?"');
      Iterable<Match> matches = regExp.allMatches(response.body);
      if (matches == null) {
        return null;
      }
      if (matches.toSet().length > 0) {
        var match = matches.first.group(1);
        return match.indexOf("https://") != -1 ? match : "$domain/$match";
      }
    } catch (e) {
      return null;
    }
  }
}
