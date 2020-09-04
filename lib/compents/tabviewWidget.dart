import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:rss/compents/rssFeedWidget.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/models/entity/tab_entity.dart';
import 'package:rss/service/tabService.dart';

class TabViewWidget extends StatefulWidget {
  final CatalogEntity catalog;
  const TabViewWidget({Key key, this.catalog}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabViewWidgetState(catalog);
  }
}

class TabViewWidgetState extends State<TabViewWidget>
    with AutomaticKeepAliveClientMixin {
  final CatalogEntity catalog;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final TabService tabService = new TabService();
  RssEntity selectedRss;
  Future<TabEntity> tab;
  bool showToTopBtn = false;
  ScrollController _scrollController;
  TabViewWidgetState(this.catalog);

  @override
  void initState() {
    super.initState();
    tab = getTab();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      print(_scrollController.offset);
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        HapticFeedback.heavyImpact(); // 震动反馈
      }
      if (_scrollController.offset >= 400 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      } else if (_scrollController.offset < 400 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  Future<TabEntity> getTab({RssEntity rssEntity, bool selected}) {
    return tabService.getTabs(catalog,
        rssEntity: rssEntity, selected: selected);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<TabEntity>(
        future: tab,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            TabEntity _tabEntity = snapshot.data;
            List<FeedsEntity> _feedsList = _tabEntity.feeds;
            List<RssEntity> _rssEntityList = _tabEntity.rss;
            return RefreshIndicator(
                child: (_tabEntity.feeds.length > 0 &&
                        _tabEntity.rss.length > 0)
                    ? Stack(children: <Widget>[
                        Column(mainAxisSize: MainAxisSize.min, children: <
                            Widget>[
                          Expanded(
                              flex: 1,
                              child: ListView.builder(
                                  itemCount: _rssEntityList.length,
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    RssEntity rssEntity = _rssEntityList[index];
                                    print("rss ${rssEntity.title}");
                                    return RawChip(
                                      avatar: (selectedRss == null ||
                                              selectedRss.id != rssEntity.id)
                                          ? null
                                          : CircleAvatar(),
                                      selected: (selectedRss == null ||
                                              selectedRss.id != rssEntity.id)
                                          ? false
                                          : true,
                                      label: Text(rssEntity.title),
                                      selectedColor: Theme.of(context)
                                          .chipTheme
                                          .selectedColor,
                                      selectedShadowColor: Theme.of(context)
                                          .chipTheme
                                          .selectedShadowColor,
                                      deleteIcon: Icon(Icons.highlight_off,
                                          color: Theme.of(context)
                                              .chipTheme
                                              .deleteIconColor,
                                          size: 18),
                                      onDeleted: () async {
                                        await _unsubcribeDialog(rssEntity);
                                      },
                                      onSelected: (value) {
                                        print("value:$value");
                                        if (selectedRss == rssEntity) {
                                          setState(() {
                                            selectedRss = null;
                                          });
                                        } else {
                                          setState(() {
                                            selectedRss = rssEntity;
                                          });
                                        }

                                        print(
                                            "selected:${selectedRss.title} selected:$value");
                                        setState(() {
                                          tab = getTab(
                                              rssEntity: selectedRss,
                                              selected: value);
                                        });
                                      },
                                    );
                                  })),
                          Expanded(
                              flex: 10,
                              child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: _feedsList.length,
                                  itemBuilder: (context, index) {
                                    FeedsEntity _feedsEntity =
                                        _feedsList[index];
                                    String _coverUrl =
                                        _feedsEntity.content == null
                                            ? null
                                            : _getFirstImageUrl(
                                                _feedsEntity.content);
                                    var _subTitle = "";
                                    if (_feedsEntity.content != null) {
                                      var document =
                                          parse(_feedsEntity.content);
                                      _subTitle = parse(document.body.text)
                                          .documentElement
                                          .text
                                          .replaceAll(
                                              RegExp('[\n|\s+|\s*]'), "")
                                          .trim()
                                          .substring(0, 30);
                                    }

                                    RssFeedListTile card = new RssFeedListTile(
                                        tab: catalog.catalog,
                                        catalogId: _feedsEntity.catalogId,
                                        coverUrl: _coverUrl,
                                        title: _feedsEntity.title
                                            .replaceAll(" ", ""),
                                        subTitle: _subTitle,
                                        publishDate: _feedsEntity.published,
                                        author: _feedsEntity.author,
                                        content: _feedsEntity.content,
                                        link: _feedsEntity.url,
                                        status: _feedsEntity.status,
                                        rssId: _feedsEntity.rssId);
                                    return card;
                                  }))
                        ]),
                        Visibility(
                            visible: showToTopBtn,
                            child: Positioned(
                                right: 20,
                                bottom: 20,
                                child: FloatingActionButton(
                                    onPressed: () {
                                      if (_scrollController.hasClients) {
                                        _scrollController.animateTo(0,
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.ease);
                                      }
                                    },
                                    child: Icon(Icons.arrow_upward))))
                      ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text("No Data")],
                      ),
                onRefresh: () {
                  bool _selected = false;
                  if (selectedRss != null) {
                    _selected = true;
                  }
                  setState(() {
                    tab = getTab(rssEntity: selectedRss, selected: _selected);
                  });
                  return tab;
                });
          }
          return Align(
              child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ));
        });
  }

  String _getFirstImageUrl(String description) {
    if (description == null) {
      return null;
    }
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

  Future<void> _unsubcribeDialog(RssEntity rssEntity) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Unsubscrie"),
          content: Text("will you unsubscrie this rss?"),
          actions: [
            FlatButton(
              child: Text("Yes"),
              onPressed: () async {
                Rss2CatalogEntity rss2catalogEntity =
                    await rss2catalogDao.findCatalogByRssId(rssEntity.id);
                await rss2catalogDao.deleteRss2Catalog(rss2catalogEntity);
                await rssDao.deleteRss(rssEntity).then((value) {
                  if (selectedRss != null && rssEntity.id == selectedRss.id) {
                    setState(() {
                      selectedRss = null;
                    });
                  }
                  setState(() {
                    tab = getTab();
                  });
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print(error.toString());
                });
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

  @override
  bool get wantKeepAlive => true;
}
