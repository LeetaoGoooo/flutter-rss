import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:provider/provider.dart';
import 'package:rss/compents/tabviewWidget.dart';
import 'package:rss/events/tabviewRefreshEvent.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/pages/catalogManage.dart';

import 'package:rss/pages/preSub.dart';
import 'package:rss/provider/theme_provider.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/tools/feedParser.dart';
import 'package:rss/tools/globalEventBus.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomeStatePage();
}

class HomeStatePage extends State<HomePage>  with TickerProviderStateMixin{
  TextEditingController _textFieldController = TextEditingController();
  bool _urlValidate = true;
  String _feedUrlHintMsg = 'Url is not validate';
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  final FeedService feedService = new FeedService();
  List<CatalogEntity> drawerMeunItems;
  List<CatalogEntity> _tabs = [CatalogEntity(-1, "All")];
  List<Widget> _tabViews = [];
  RssEntity selectedRss;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<GlobalKey<TabViewWidgetState>> _tabKeys = [];
  TabController _tabController;
  IconData _unread = Icons.radio_button_unchecked;
  IconData _star = Icons.star_border;
  IconData _all = Icons.view_list;
  bool _switchValue = false;
  final GlobalEventBus eventBus = new GlobalEventBus();


  @override
  void initState() {
    super.initState();
    var _key = GlobalKey<TabViewWidgetState>();
    _tabKeys.add(_key);
    _tabViews.add(TabViewWidget(key: _key, catalog: _tabs[0]));
    _tabController = new TabController(length: _tabs.length, vsync: this);
    loadTabController();
  }

  loadTabController() {
     _getAllCatalogs().then((value) {
      List<Widget> _widgets = [];
      value.forEach((element) {
        if(_tabs.indexOf(element) != -1) {
          return;
        }
        var _key = GlobalKey<TabViewWidgetState>();
        _tabKeys.add(_key);
        _widgets.add(TabViewWidget(key: _key, catalog: element));
      });
      setState(() {
        _tabs += value;
        _tabViews += _widgets;
        _tabController = new TabController(length: _tabs.length, vsync: this)
          ..addListener(() {
            if (_tabController.index.toDouble() ==
                _tabController.animation.value) {
              _filtersBtton(0);
            }
          });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {
                  //
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add New Rss Source',
                onPressed: () {
                  _displayDialog(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.done),
                tooltip: 'Make All Read',
                onPressed: () {
                  // openPage(context);
                  _showReadBottomSheet(context);
                },
              ),
            ],
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: Theme.of(context).indicatorColor,
                          tabs: _tabs
                              .map((CatalogEntity catalog) =>
                                  Tab(text: catalog.catalog))
                              .toList())),
                ))),
        drawer: Drawer(
            child: Container(
                child: Column(children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(),
              currentAccountPicture: new CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color(0xFF778899),
                backgroundImage: AssetImage('assets/default.png'),
              ),
              accountName: Text(
                "author:Leetao"
              ),
              accountEmail: Text("leetao94@gmail.com")),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 18.0, 0.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Settings",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          // _buildDrawerMenu(context),
          // Divider(),
          ListTile(
            leading: Icon(Icons.class_),
            title: Text("Catalogs"),
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new CatalogManage();
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            title: Text("Dark Model"),
            trailing: Switch(
                value: _switchValue,
                onChanged: (value) {
                  ThemeMode themeMode =
                      value ? ThemeMode.dark : ThemeMode.light;
                  Provider.of<ThemeProvider>(context, listen: false).setTheme(themeMode);
                  setState(() {
                    _switchValue = value;
                  });
                }),
            // onTap: () {},
          )
        ]))),
        body: new Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: TabBarView(
                      controller: _tabController, children: _tabViews))
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: Row(
              children: [
                Spacer(),
                IconButton(
                    icon: Icon(_all,color: Theme.of(context).appBarTheme.iconTheme.color,),
                    onPressed: () {
                      _filterFeeds(0);
                    }),
                IconButton(
                  icon: Icon(
                    _unread,
                    color: Theme.of(context).appBarTheme.iconTheme.color
                  ),
                  onPressed: () {
                    _filterFeeds(1, status: 0);
                  },
                ),
                IconButton(
                    icon: Icon(
                      _star,
                      color: Theme.of(context).appBarTheme.iconTheme.color
                    ),
                    onPressed: () {
                      _filterFeeds(2, status: 0);
                    })
              ],
            )));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
              title: Text("Add Subscription", textAlign: TextAlign.center),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: _textFieldController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: 'Feed or Site Url',
                          errorText: _urlValidate ? null : _feedUrlHintMsg),
                      onChanged: (url) async {
                        if (url.isNotEmpty) {
                          await rssDao
                              .findRssByUrl(url)
                              .then((RssEntity value) {
                            if (value != null) {
                              setState(() {
                                _urlValidate = false;
                                _feedUrlHintMsg = 'This url already existed!';
                              });
                            } else {
                              setState(() {
                                _urlValidate = true;
                              });
                            }
                          });
                        } else {
                          setState(() {
                            _urlValidate = true;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    ),
                    ProgressButton(
                      defaultWidget: const Text('SEARCH'),
                      progressWidget: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                      color: _urlValidate
                          ? Theme.of(context).buttonTheme.colorScheme.primary
                          : Theme.of(context).disabledColor,
                      width: 110,
                      onPressed: !_urlValidate
                          ? null
                          : () async {
                              print("url validate:$_urlValidate");
                              FeedParser feedParser = new FeedParser(
                                  url: _textFieldController.value.text
                                      .trim()
                                      .toString());
                              await feedParser.parseRss().then((value) {
                                _navigatortoPreSub(
                                    context,
                                    value.title,
                                    _textFieldController.value.text
                                        .trim()
                                        .toString(),
                                    'rss');
                                setState(() {
                                  _urlValidate = true;
                                });
                              }).catchError((e) {
                                feedParser.parseAtom().then((value) {
                                  _navigatortoPreSub(
                                      context,
                                      value.title,
                                      _textFieldController.value.text
                                          .trim()
                                          .toString(),
                                      'atom');
                                  setState(() {
                                    _urlValidate = true;
                                  });
                                }).catchError((e) {
                                  setState(() {
                                    _urlValidate = false;
                                  });
                                });
                              });
                            },
                    ),
                    new Divider(),
                    new FittedBox(
                      child: new FlatButton(
                        // textColor: Theme.of(context).buttonTheme.colorScheme.primary,
                        onPressed: () async {
                          File file = await FilePicker.getFile(
                              type: FileType.custom,
                              allowedExtensions: ['opml']);
                          if (file != null) {
                            print("parse...");
                            await feedService.parseOPML(file).then((value) => {
                              loadTabController()
                            });
                          }
                        },
                        child: Text("Import from OPML"),
                      ),
                    )
                  ]));
        });
      },
    ).then((value) {
      _textFieldController.clear();
    });
  }

  void _navigatortoPreSub(BuildContext contentext, title, url, type) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new PreSubPage(title: title, type: type, feedsUrl: url);
    }));
  }

  Widget _buildDrawerMenu(BuildContext context) {
    return FutureBuilder(
      builder: (context, snap) {
        if (!snap.hasData) return CircularProgressIndicator();
        if (snap.data == null) {
          return Container();
        }
        drawerMeunItems = snap.data;
        return Expanded(
            child: ListView.builder(
          shrinkWrap: true,
          itemCount: drawerMeunItems.length,
          itemBuilder: (BuildContext context, int index) {
            CatalogEntity catalog = drawerMeunItems[index];
            return _buildDrawerMenuItem(catalog);
          },
        ));
      },
      future: _getAllCatalogs(),
    );
  }

  Widget _buildDrawerMenuItem(CatalogEntity catalogEntity) {
    return ListTile(
        hoverColor: Colors.purple[100],
        autofocus: true,
        title: Text(
          catalogEntity.catalog,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {});
  }

  Future<List<CatalogEntity>> _getAllCatalogs() {
    return catalogDao.findAllCatalogs();
  }

  void _filterFeeds(int type, {status}) {
    _filtersBtton(type);
    if (type == 2) {
      _getFavorites();
    } else {
      int index = _tabController.index;
      print("current index:$index,current state:${_tabKeys[index]}");
      _tabKeys[index].currentState?.filterFeeds(status: status);
    }
  }

  void _getFavorites() {
    int index = _tabController.index;
    print("current index:$index,current state:${_tabKeys[index]}");
    _tabKeys[index].currentState?.getFavorites();
  }

  void _filtersBtton(int type) {
    switch (type) {
      case 0:
        eventBus.event.fire(TabViewRefreshvent(true));
        setState(() {
          _all = Icons.view_list;
          _star = Icons.star_border;
          _unread = Icons.radio_button_unchecked;
        });
        break;
      case 1:
        setState(() {
          _all = Icons.format_list_bulleted;
          _star = Icons.star_border;
          _unread = Icons.radio_button_checked;
        });
        break;
      case 2:
        setState(() {
          _all = Icons.format_list_bulleted;
          _star = Icons.star;
          _unread = Icons.radio_button_unchecked;
        });
        break;
      default:
    }
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
                  int index = _tabController.index;
                  _tabKeys[index].currentState?.makeAllFeedsRead();
                  Navigator.pop(context);
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
}
