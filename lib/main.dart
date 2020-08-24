import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entities.dart';
import 'package:rss/pages/preSub.dart';
import 'models/dao/rss_dao.dart';
import 'models/database.dart';
import 'models/entity/rss_entity.dart';
import 'tools/feedParser.dart';
import 'constants/globals.dart' as g;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await $FloorAppDatabase.databaseBuilder('rss.db').build().then((database) {
    g.catalogDao = database.catalogDao;
    g.rssDao = database.rssDao;
    g.rss2catalogDao = database.rss2catalogDao;
  });

  runApp(PeachRssApp());
}

class PeachRssApp extends StatelessWidget {
  static const String _title = 'RSS';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: _title, home: PeachRssHomeWidget());
  }
}

class PeachRssHomeWidget extends StatefulWidget {
  PeachRssHomeWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PeachRssHomeWidget>
    with SingleTickerProviderStateMixin {
  TextEditingController _textFieldController = TextEditingController();
  bool _urlValidate = true;
  String _feedUrlHintMsg = 'Url is not validate';
  final RssDao rssDao = g.rssDao;
  final CatalogDao catalogDao = g.catalogDao;
  final Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  List<CatalogEntity> drawerMeunItems;
  List<RssEntity> rssMenuItems;
  List<CatalogEntity> _tabs = [];
  RssEntity selectedRss;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _tapDownPosition;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getAllCatalogs().then((value) {
      CatalogEntity catalogEntity = new CatalogEntity(-1, "All");
      _tabs.add(catalogEntity);
      setState(() {
        _tabs += value;
        print('..._tabController init...:_tabs length:${_tabs.length}');
        _tabController = new TabController(length: _tabs.length, vsync: this);
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
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
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
                },
              ),
            ],
            bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs
                    .map((CatalogEntity catalog) => Tab(text: catalog.catalog))
                    .toList()),
          ),
          drawer: Drawer(
              child: Container(
                  child: Column(children: <Widget>[
            UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
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
                  "Catalogs",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            _buildDrawerMenu(context),
          ]))),
          body: new Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildRssMenu(context),
                Expanded(
                    child: TabBarView(
                  controller: _tabController,
                  children: _tabs
                      .map((CatalogEntity catalog) =>
                          Center(child: Text("Tab ${catalog.catalog}'s view")))
                      .toList(),
                ))
              ],
            ),
          ),
        ));
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
                      color: _urlValidate ? Colors.blue : Colors.grey,
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
                        textColor: Colors.blue,
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
            return GestureDetector(
                onTapDown: (details) {
                  _tapDownPosition = details.globalPosition;
                },
                onLongPress: () {
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject();
                  var _position = RelativeRect.fromRect(
                      _tapDownPosition &
                          const Size(40, 40), // smaller rect, the touch area
                      Offset.zero &
                          overlay.size // Bigger rect, the entire screen
                      );
                  showMenu(
                    position: _position,
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        value: catalog,
                        child: Column(
                          children: <Widget>[
                            Text(
                              catalog.catalog,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Divider()
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: catalog,
                        child: FlatButton.icon(
                            icon: Icon(Icons.delete),
                            label: Text("Delete"),
                            onPressed: () {
                              print('delete $catalog');
                            }),
                      ),
                      PopupMenuItem(
                          value: catalog,
                          child: FlatButton.icon(
                              icon: Icon(Icons.edit),
                              label: Text("Edit"),
                              onPressed: () {}))
                    ],
                    context: context,
                  ).then((value) => null);
                },
                child: _buildDrawerMenuItem(catalog));
          },
        ));
      },
      future: _getAllCatalogs(),
    );
  }

  Widget _buildDrawerMenuItem(CatalogEntity catalogEntity) {
    return ListTile(
        leading: Icon(Icons.loyalty),
        title: Text(catalogEntity.catalog),
        trailing: Chip(label: Text("0")),
        onTap: () async{
          _tabController.animateTo(_tabs.indexOf(catalogEntity));
          _getRssByCatalog(catalogEntity);
          Navigator.pop(context);
        });
  }

  void _getRssByCatalog(CatalogEntity catalogEntity) async {
    print('...loading');
    List<RssEntity> rssList = [];
    await rssDao.findMultiRssByCatalogId(catalogEntity.id)
    .then((List<MultiRssEntity> multiRssList) {
      multiRssList.forEach((MultiRssEntity multiRssEntity) { 
        RssEntity rssItem = new RssEntity(multiRssEntity.rssId, multiRssEntity.rssTitle, multiRssEntity.rssUrl, multiRssEntity.rssType);
        rssList.add(rssItem);
        setState(() {
          rssMenuItems = rssList;
        });
      });
    });
  }


  Future<List<CatalogEntity>> _getAllCatalogs() {
    return catalogDao.findAllCatalogs();
  }

  Widget _buildRssMenu(BuildContext context) {
    return SizedBox(
        height: 60,
        child: FutureBuilder(
          builder: (context, snap) {
            if (!snap.hasData) return LinearProgressIndicator();
            if (snap.data == null) {
              return Container();
            }
            rssMenuItems = snap.data;
            return ListView.separated(
              itemCount: rssMenuItems.length,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(12.0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return _buildRssMenuItem(rssMenuItems[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            );
          },
          future: _getAllRssEntites(),
        ));
  }

  Widget _buildRssMenuItem(RssEntity rssEntity) {
    return RawChip(
      avatar: (selectedRss == null || selectedRss.id != rssEntity.id)
          ? null
          : CircleAvatar(),
      selected: (selectedRss == null || selectedRss.id != rssEntity.id)
          ? false
          : true,
      label: Text(rssEntity.title),
      selectedColor: Theme.of(context).chipTheme.selectedColor,
      selectedShadowColor: Theme.of(context).chipTheme.selectedShadowColor,
      deleteIcon: Icon(Icons.highlight_off,
          color: Theme.of(context).chipTheme.deleteIconColor, size: 18),
      onDeleted: () async {
        await _unsubcribeDialog(rssEntity);
      },
      onSelected: (value) {
        if (selectedRss == rssEntity) {
          setState(() {
            selectedRss = null;
          });
        } else {
          setState(() {
            selectedRss = rssEntity;
          });
        }
      },
    );
  }

  Future<List<RssEntity>> _getAllRssEntites() {
    return rssDao.findAllRss();
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
                await rssDao.deleteRss(rssEntity).then((value) {
                  if (selectedRss != null && rssEntity.id == selectedRss.id) {
                    setState(() {
                      selectedRss = null;
                    });
                  }
                  Navigator.of(context).pop();
                }).catchError((error) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("dimiss this rss failed!"),
                    behavior: SnackBarBehavior.floating,
                  ));
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
}
