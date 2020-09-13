import 'dart:async';
import 'dart:collection';

/// file        : catalogManage.dart
/// descrption  :  分类管理页面
/// date        : 2020/09/06 20:11:44
/// author      : Leetao

import 'package:flutter/material.dart';
import 'package:rss/compents/rssCardWidget.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:http/http.dart' as http;
import 'package:rss/pages/catalogSetting.dart';
import 'package:rss/service/feedService.dart';

class CatalogManage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CatalogManageStateWidget();
}

class CatalogManageStateWidget extends State<CatalogManage> {
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  final FeedService feedService = new FeedService();
  final client = http.Client();
  Future<List<MultiRssEntity>> multiRssList;
  List<Widget> _avatars = [];
  Map _rssMap = HashMap();
  List<String> _catalogList = [];

  @override
  void initState() {
    super.initState();
    multiRssList = getAllMultiRssEntity();
  }

  Future<List<MultiRssEntity>> getAllMultiRssEntity() async {
    print("getAllMultiRssEntity");
    List<MultiRssEntity> _multiRssList = await rssDao.findAllMultiRss();
    print("get $_multiRssList");
    List<String> _webSiteUrl = [];
    List<String> _rssIdList = [];
    List<String> _tmpCatalog = [];

    for (MultiRssEntity multiRssEntity in _multiRssList) {
      _webSiteUrl.add(multiRssEntity.rssUrl);
      _rssIdList.add(multiRssEntity.rssId.toString());
      var _catalog = await catalogDao.findCatalogById(multiRssEntity.catalogId);
      _tmpCatalog.add(_catalog?.catalog);
    }
    print(_webSiteUrl);
    List<Widget> _tmpAvatars = await _getAllWebSiteIcon(_webSiteUrl);
        print("_getRssReadMap");
    Map _tmpRssMap = await _getRssReadMap(_rssIdList);
    setState(() {
      _catalogList = _tmpCatalog;
      _avatars = _tmpAvatars;
      _rssMap = _tmpRssMap;
    });
    // print("mutiRssList length:${_multiRssList?.length}");
    return _multiRssList;
  }

  @override
  Widget build(BuildContext context) {
    print("build...");
    return Scaffold(
      appBar: AppBar(
        title: Text("CatalogManage"),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            }),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new CatalogSetting();
                }));
              })
        ],
      ),
      body: FutureBuilder<List<MultiRssEntity>>(
        future: multiRssList,
        builder: (context, AsyncSnapshot<List<MultiRssEntity>> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            print("data length:${snapshot.data.length}");
            List<MultiRssEntity> rssList = snapshot.data;
            return RefreshIndicator(
              child: GridView.builder(
                  itemCount: rssList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    MultiRssEntity multiRssEntity = rssList[index];
                    print(multiRssEntity.toJson());
                    return RssCard(
                      avatar: _avatars[index],
                      title: multiRssEntity.rssTitle,
                      subTitle: _catalogList[index] == null
                          ? "All"
                          : _catalogList[index],
                      all: _rssMap[multiRssEntity.rssId.toString()] == null
                          ? "NaN"
                          : _rssMap[multiRssEntity.rssId.toString()]["all"],
                      read: _rssMap[multiRssEntity.rssId.toString()] == null
                          ? "NaN"
                          : _rssMap[multiRssEntity.rssId.toString()]["read"],
                      unread: _rssMap[multiRssEntity.rssId.toString()] == null
                          ? "NaN"
                          : _rssMap[multiRssEntity.rssId.toString()]["unread"],
                      rssId: multiRssEntity.rssId,
                      catalogId: multiRssEntity.catalogId,
                      url: multiRssEntity.rssUrl,
                      voidCallback: refresh,
                    );
                  }),
              onRefresh: refresh,
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

  Future<List<Widget>> _getAllWebSiteIcon(List<String> urlList) async {
    List<Widget> _widgets = [];
    for (var i = 0; i < urlList.length; i++) {
      var _widget = await _getWebSiteIcon(urlList[i]);
      _widgets.add(_widget);
    }
    return _widgets;
  }

  Future<Map> _getRssReadMap(List<String> rssIdList) async {
    print("rssIdList :$rssIdList");
    int rssLen = rssIdList.length;
    var _map = HashMap();
    for (var i = 0; i < rssLen; i++) {
      _map[rssIdList[i]] = await feedService.getFeedReadStatus(rssIdList[i]);
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

  Future<void> refresh() {
    setState(() {
      multiRssList = getAllMultiRssEntity();
    });
    return multiRssList;
  }
}
