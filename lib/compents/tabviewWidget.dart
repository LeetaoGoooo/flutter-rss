import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:rss/compents/rssFeedWidget.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/events/tabviewFeedEvent.dart';
import 'package:rss/events/tabviewRssEvent.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/service/rssService.dart';
import 'package:rss/service/tabService.dart';
import 'package:rss/tools/globalEventBus.dart';

class TabViewWidget extends StatefulWidget {
  final CatalogEntity catalog;
  const TabViewWidget({Key key, this.catalog}) : super(key: key);

  @override
  TabViewWidgetState createState() {
    return TabViewWidgetState(catalog);
  }
}

class TabViewWidgetState extends State<TabViewWidget> {
  final CatalogEntity catalog;
  final RssDao rssDao = g.rssDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  final TabService tabService = new TabService();
  RssEntity selectedRss;
  bool showToTopBtn = false;
  bool showProgressBar = true;
  List<FeedsEntity> feedList = [];
  List<RssEntity> rssList = [];
  final RssService rssService = new RssService();
  final GlobalEventBus eventBus = new GlobalEventBus();

  ScrollController _scrollController;

  TabViewWidgetState(this.catalog);

  @override
  void initState() {
    super.initState();

    eventBus.event.on<TabViewRssEvent>().listen((events) {
      if (events.rssList.length > 0 && events.catalog == catalog) {
        addRss(list: events.rssList);
      }
    });

    eventBus.event.on<TabViewFeedEvent>().listen((events) {
      print("当前接受 catalog:${events.catalog.catalog} 当前 catalog: ${catalog.catalog}");
      if (events.catalog.id != catalog.id && catalog.id != -1) {
        return;
      }

      // All tab 页只接受更新的 feed 推送
      if (events.feed != null) {
        addFeed(feed: events.feed);
      }
      print("推送 feeds 长度:${events.feeds?.length}");

      if (events.feeds != null && catalog.id == events.catalog.id) {
        addFeed(feeds: events.feeds);
      }
    });

    getTab();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
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

  addRss({RssEntity rss, List<RssEntity> list}) {
    if (this.mounted) {
      if (rss != null) {
        setState(() {
          rssList.add(rss);
        });
      }
      print("更新rss");
      if (list != null && this.mounted) {
        setState(() {
          rssList = list;
        });
      }
    }
  }

  addFeed({FeedsEntity feed, List<FeedsEntity> feeds}) {
    if (feed != null) {
      if (this.mounted && feedList.indexOf(feed) == -1 && feed != null) {
          feedList.add(feed);
          feedList.sort((a, b) => b.published.compareTo(a.published));

        setState(() {
          feedList = feedList;
          showProgressBar = false;
        });
      }
    }
    if (feeds != null && this.mounted) {
      setState(() {
        feedList = feeds;
        showProgressBar = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  Future<void> getTab({RssEntity rssEntity, bool selected, int status}) async {
    await tabService.getTabs(catalog,
        rssEntity: selectedRss, selected: selected, status: status);
  }

  getTabViewData({RssEntity rssEntity, bool selected, int status}) async {
    List<RssEntity> tmpRssList = await rssService.getRssList(catalog);
    setState(() {
      rssList = tmpRssList;
    });
    if (rssEntity == null && selected == null) {}
  }

  Future<void> filterFeeds(
      {RssEntity rssEntity, bool selected, int status}) async {
    bool selected = false;
    if (selectedRss != null) {
      selected = true;
    }
    print(
        "current catalog:${catalog.catalog} selectedRss:${selectedRss?.title} status:$status");
    await tabService.getTabs(catalog,
        rssEntity: selectedRss, selected: selected, status: status);
  }

  Future<void> getFavorites() async {
    await tabService.getFavorites(catalog, rssId: selectedRss?.id);
  }

  Future<void> makeAllFeedsRead() async {
    bool selected = false;
    if (selectedRss != null) {
      selected = true;
    }
    await tabService.makeFeedsRead(catalog,
        rssEntity: selectedRss, selected: selected);
    await getTab(rssEntity: selectedRss, selected: selected);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: (feedList.length > 0 || rssList.length > 0)
            ? Stack(children: <Widget>[
                Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: ListView.builder(
                              itemCount: rssList.length,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                RssEntity rssEntity = rssList[index];
                                print(
                                    "catalog ${catalog.catalog} rss ${rssEntity.title}");
                                return Padding(
                                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    child: RawChip(
                                      avatar: (selectedRss == null ||
                                              selectedRss.id != rssEntity.id)
                                          ? null
                                          : CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .chipTheme
                                                  .backgroundColor),
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
                                      deleteIcon: Icon(Icons.cancel,
                                          color: Theme.of(context)
                                              .chipTheme
                                              .deleteIconColor,
                                          size: 18),
                                      onDeleted: () async {
                                        await _unsubcribeDialog(rssEntity);
                                      },
                                      onSelected: (value) {
                                        print(
                                            "value:$value selectedRss:${selectedRss?.title} ${rssEntity.title}");
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
                                            "selected:${selectedRss?.title} selected:$value");
                                        getTab(
                                            rssEntity: selectedRss,
                                            selected: value);
                                      },
                                    ));
                              }))),
                  Visibility(
                      visible: showProgressBar,
                      child: LinearProgressIndicator()),
                  Expanded(
                      flex: 10,
                      child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: feedList.length,
                          itemBuilder: (context, index) {
                            return _buildRssFeedListTileItem(feedList[index]);
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
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.ease);
                              }
                            },
                            child: Icon(Icons.arrow_upward))))
              ])
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Container()],
              ),
        onRefresh: () async {
          bool _selected = false;
          if (selectedRss != null) {
            _selected = true;
          }
          await getTab(rssEntity: selectedRss, selected: _selected);
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
                  getTab();
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

  Widget _buildRssFeedListTile(FeedsEntity current,
      {FeedsEntity pre, FeedsEntity next}) {}

  Widget _buildRssFeedListTileItem(FeedsEntity feed) {
    FeedsEntity _feedsEntity = feed;
    String _coverUrl = _feedsEntity.content == null
        ? null
        : _getFirstImageUrl(_feedsEntity.content);
    var _subTitle = "";
    if (_feedsEntity.content != null) {
      var document = parse(_feedsEntity.content);
      _subTitle = parse(document.body.text)
          .documentElement
          .text
          .replaceAll(RegExp('[\n|\s+|\s*]'), "")
          .trim()
          .substring(0, 30);
    }

    RssFeedListTile card = new RssFeedListTile(
        key: ValueKey(_feedsEntity.url),
        tab: catalog.catalog,
        catalogId: _feedsEntity.catalogId,
        coverUrl: _coverUrl,
        title: _feedsEntity.title.replaceAll(" ", ""),
        subTitle: _subTitle,
        publishDate: _feedsEntity.published,
        author: _feedsEntity.author,
        content: _feedsEntity.content,
        link: _feedsEntity.url,
        status: _feedsEntity.status,
        rssId: _feedsEntity.rssId);
    return card;
  }
}
