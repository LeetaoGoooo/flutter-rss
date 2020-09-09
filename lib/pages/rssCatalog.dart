// rss 分类页面

import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/dao/rss2catalog_dao.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss2catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/constants/globals.dart' as g;


class RssCatalogPage extends StatefulWidget {
  final String title;
  final String feedsUrl;
  final String type;

  RssCatalogPage({Key key, this.title, this.feedsUrl, this.type})
      : super(key: key);

  @override
  _RssCatalogWidget createState() => _RssCatalogWidget(title, feedsUrl, type);
}

class _RssCatalogWidget extends State<RssCatalogPage> {
  final String title;
  final String feedsUrl;
  final String type;
  bool _validateCatalog = true;
  int _waits = 3;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<CatalogEntity> selectedCatalogs = [];
  CatalogDao catalogDao = g.catalogDao;
  RssDao rssDao = g.rssDao;
  Rss2CatalogDao rss2catalogDao = g.rss2catalogDao;
  List<CatalogEntity> items = [];
  TextEditingController _newCatalogController = TextEditingController();

  _RssCatalogWidget(this.title, this.feedsUrl, this.type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Add to Folder"),
          actions: [
            IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Add',
              onPressed: () async {
                await _subscribeRss();
              },
            )
          ],
        ),
        body: new Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              TextField(
                controller: _newCatalogController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.rss_feed),
                    labelText: "Input new catalogs",
                    errorText: _validateCatalog ? null : 'This Catalog exists'),
                onChanged: (catalogName) async {
                  if (catalogName.trim().isEmpty) {
                    return;
                  }
                  catalogDao
                      .findCatalogByCatalog(catalogName)
                      .then((catalogEntity) {
                    if (catalogEntity != null) {
                      setState(() {
                        _validateCatalog = false;
                      });
                    } else {
                      setState(() {
                        _validateCatalog = true;
                      });
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
              ),
              ListTile(
                title: Text(
                  "CATALOGS",
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              _buildExistsCatalogs(context),
            ])),
        floatingActionButton: FloatingActionButton.extended(
            label: Text("Subscribe"),
            icon: Icon(Icons.done),
            onPressed: () async {
              await _subscribeRss();
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  Future<void> _subscribeRss() async {
    await _insertRss2DB().then((List<int> valueList) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Add Rss Successfully,will Go to Home in $_waits s'),
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

  @transaction
  Future<List<int>> _insertRss2DB() async {
    RssEntity rssEntity = new RssEntity(null, title, feedsUrl, type);
    List<Rss2CatalogEntity> rss2CatalogEntities = [];

    // 新增当前 rss 源
    var rssId = await rssDao.insertRss(rssEntity);
    // 判断是否新增 catalog
    var newCatalog = _newCatalogController.text.trim();
    if (newCatalog.isNotEmpty) {
      print("newCatalog  is not empty");
      CatalogEntity catalogEntityNew = new CatalogEntity(null, newCatalog);
      var catalogId = await catalogDao.insertCatalog(catalogEntityNew);
      Rss2CatalogEntity rss2catalogEntity =
          new Rss2CatalogEntity(null, catalogId, rssId);
      rss2CatalogEntities.add(rss2catalogEntity);
    }
    if (selectedCatalogs.isNotEmpty) {
      print("selectedCatalogs  is not empty");

      selectedCatalogs.forEach((CatalogEntity catalogEntity) {
        Rss2CatalogEntity entity =
            new Rss2CatalogEntity(null, catalogEntity.id, rssId);
        rss2CatalogEntities.add(entity);
      });
    }
    if (rss2CatalogEntities.length == 0) {
      print("rss2CatalogEntities  is  empty");
      Rss2CatalogEntity defaultEntity = new Rss2CatalogEntity(null, -1, rssId);
      rss2CatalogEntities.add(defaultEntity);
    }
    return rss2catalogDao.insertRss2CatalogList(rss2CatalogEntities);
  }

  Widget _buildExistsCatalogs(BuildContext context) {
    return FutureBuilder(
      builder: (context, snap) {
        if (!snap.hasData) return LinearProgressIndicator();
        if (snap.data == null) {
          return Container();
        }
        items = snap.data;
        return Expanded(
            child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            CatalogEntity catalog = items[index];
            return _buildCatalogItem('', catalog);
          },
        ));
      },
      future: _getAllCatalogs(),
    );
  }

  Future<List<CatalogEntity>> _getAllCatalogs() {
    return catalogDao.findAllCatalogs();
  }

  Widget _buildCatalogItem(String imagePath, CatalogEntity catalog) {
    return Dismissible(
      key: Key(catalog.catalog),
      onDismissed: (direction) async {
        items.remove(catalog);
        var catalogName = catalog.catalog;
        await catalogDao.deleteCatalog(catalog).then((value) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Catalog $catalogName dismissed'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  CatalogEntity catalogUndo =
                      new CatalogEntity(null, catalog.catalog);
                  await catalogDao.insertCatalog(catalogUndo);
                  setState(() {});
                }),
          ));
          setState(() {});
        }).catchError((error) {
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Catalog $catalogName dismiss failed!")));
        });
      },
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          child: Icon(Icons.delete, color: Colors.white),
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        ),
      ),
      child: ListTile(
          leading: FlutterLogo(),
          title: Text(catalog.catalog),
          trailing: Checkbox(
              value: selectedCatalogs.contains(catalog),
              onChanged: (value) {
                if (value) {
                  setState(() {
                    selectedCatalogs.add(catalog);
                  });
                } else {
                  setState(() {
                    selectedCatalogs.remove(catalog);
                  });
                }
              })),
    );
  }
}
