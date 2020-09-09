import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:rss/compents/tabviewWidget.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/pages/catalogManage.dart';

import 'package:rss/pages/preSub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/dao/rss_dao.dart';
import 'models/database.dart';
import 'models/entity/rss_entity.dart';
import 'tools/feedParser.dart';
import 'constants/globals.dart' as g;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final migration4to5 = Migration(4, 5, (database) async {
  //   await database.execute('DELETE FROM rss');
  // });
  await $FloorAppDatabase
      .databaseBuilder('rss-v001.db')
      // .addMigrations([migration4to5])
      .build()
      .then((database) {
    g.catalogDao = database.catalogDao;
    g.rssDao = database.rssDao;
    g.rss2catalogDao = database.rss2catalogDao;
    g.feedsDao = database.feedsDao;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  runApp(PeachRssApp());
}

class PeachRssApp extends StatelessWidget {
  static const String _title = 'RSS';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: Colors.purple,
            accentColor: Colors.deepPurple),
        title: _title,
        home: PeachRssHomeWidget());
  }
}

class PeachRssHomeWidget extends StatefulWidget {
  PeachRssHomeWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PeachRssHomeWidget>
    with TickerProviderStateMixin {
  TextEditingController _textFieldController = TextEditingController();
  bool _urlValidate = true;
  String _feedUrlHintMsg = 'Url is not validate';
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
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

  @override
  void initState() {
    super.initState();
    var _key = GlobalKey<TabViewWidgetState>();
    _tabKeys.add(_key);
    _tabViews.add(TabViewWidget(key: _key, catalog: _tabs[0]));
    _tabController = new TabController(length: _tabs.length, vsync: this);
    _getAllCatalogs().then((value) {
      List<Widget> _widgets = [];
      value.forEach((element) {
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
        appBar: GradientAppBar(
            // elevation: 0,
            backgroundColorStart: Colors.deepPurple,
            backgroundColorEnd: Colors.purple,
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
                          indicatorColor: Colors.pinkAccent,
                          tabs: _tabs
                              .map((CatalogEntity catalog) =>
                                  Tab(text: catalog.catalog))
                              .toList())),
                ))),
        drawer: Drawer(
            child: Container(
                child: Column(children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                    Colors.purple,
                    Colors.deepPurple,
                  ])),
              currentAccountPicture: new CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color(0xFF778899),
                backgroundImage: AssetImage('assets/default.png'),
              ),
              accountName: Text(
                "author:Leetao",
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text("leetao94@gmail.com",
                  style: TextStyle(color: Colors.white))),
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
            leading: Icon(Icons.lightbulb_outline),
            title: Text("Dark Model"),
            onTap: () {},
          )
        ]))),
        body: new Container(
          color: Colors.white,
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
            color: Colors.purple,
            child: Row(
              children: [
                Spacer(),
                IconButton(
                    icon: Icon(_all, color: Colors.white),
                    onPressed: () {
                      _filterFeeds(0);
                    }),
                IconButton(
                  icon: Icon(
                    _unread,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _filterFeeds(1, status: 0);
                  },
                ),
                IconButton(
                    icon: Icon(
                      _star,
                      color: Colors.white,
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
                              .then((List<RssEntity> value) {
                            if (value.length > 0) {
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
                      defaultWidget: const Text('SEARCH',
                          style: TextStyle(color: Colors.white)),
                      progressWidget: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                      color: _urlValidate ? Colors.deepPurple : Colors.grey,
                      width: 110,
                      onPressed: !_urlValidate
                          ? null
                          : () async {
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
                        textColor: Colors.deepPurple,
                        onPressed: () async {
                          File file = await FilePicker.getFile(
                              type: FileType.any, allowedExtensions: ['opml']);
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
