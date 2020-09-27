/// file        : catalogSetting.dart
/// descrption  : catalog 设置页面
/// date        : 2020/09/10 09:35:15
/// author      : Leetao

import 'package:flutter/material.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/models/entity/catalog_entity.dart';

class CatalogSetting extends StatefulWidget {
  @override
  CatalogSettingState createState() => CatalogSettingState();
}

class CatalogSettingState extends State<CatalogSetting> {
  final CatalogDao catalogDao = g.catalogDao;
  Future<List<CatalogEntity>> catalogs;
  TextEditingController _newCatlogController = new TextEditingController();
  TextEditingController _editCatlogController = new TextEditingController();

  String _errorNewCatalogMsg;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    catalogs = getAllCatalogs();
  }

  @override
  Widget build(BuildContext context) {
    print("build...");
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("CatalogSettings",style: Theme.of(context).appBarTheme.textTheme.subtitle1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await _showAddCatalogDialog();
              })
        ],
      ),
      body: Container(
          child: FutureBuilder(
              future: catalogs,
              builder: (context, snap) {
                if (snap.hasData &&
                    snap.connectionState == ConnectionState.done) {
                  List<CatalogEntity> catalogList = snap.data;
                  print("data length:${catalogList.length}");
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: catalogList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                                title: Text(catalogList[index].catalog),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () async {
                                            await _editCatalogDialog(
                                                catalogList[index]);
                                          }),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await _removeCatalogDialog(
                                              catalogList[index]);
                                        },
                                      )
                                    ])));
                      });
                }
                if (snap.hasError) {
                  return Container();
                }
                return Align(child: CircularProgressIndicator());
              })),
    );
  }

  Future<void> _editCatalogDialog(CatalogEntity catalog) async {
    _editCatlogController.value = TextEditingValue(text: catalog.catalog);
    return showDialog(
        context: context,
        // barrierDismissible: false, // user must tap button!
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Catalog'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _editCatlogController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Catalog Name',
                          errorText: _errorNewCatalogMsg),
                      onChanged: (String value) async {
                        if (value.trim().isEmpty) return;
                        await catalogDao
                            .findCatalogByCatalog(value.trim())
                            .then((catalog) {
                          if (catalog != null) {
                            setState(() {
                              _errorNewCatalogMsg =
                                  "Catalog is already existed!";
                            });
                          } else {
                            setState(() {
                              _errorNewCatalogMsg = null;
                            });
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCLE'),
                  onPressed: () {
                    _editCatlogController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                    child: Text('SAVE'),
                    onPressed: _errorNewCatalogMsg != null
                        ? null
                        : () async {
                            await _editCatalog(catalog);
                          }),
              ],
            );
          });
        });
  }

  Future<void> _removeCatalogDialog(CatalogEntity catalog) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text("DELETE"),
              content: Text("Will you remove ${catalog?.catalog}?"),
              actions: [
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () async {
                    await _removeCatalog(catalog);
                  },
                ),
                FlatButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: Text("No"))
              ],
            );
          });
        });
  }

  Future<List<CatalogEntity>> getAllCatalogs() async {
    print("get all catalogs");
    return await catalogDao.findAllCatalogs();
  }

  Future<void> _showAddCatalogDialog() async {
    _newCatlogController.clear();
    return showDialog(
        context: context,
        // barrierDismissible: false, // user must tap button!
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text('New Catalog'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Catalog Name',
                          errorText: _errorNewCatalogMsg),
                      onChanged: (String value) async {
                        if (value.trim().isEmpty) return;
                        await catalogDao
                            .findCatalogByCatalog(value.trim())
                            .then((catalog) {
                          if (catalog != null) {
                            setState(() {
                              _errorNewCatalogMsg =
                                  "Catalog is already existed!";
                            });
                          } else {
                            setState(() {
                              _errorNewCatalogMsg = null;
                            });
                          }
                        });
                      },
                      controller: _newCatlogController,
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCLE'),
                  onPressed: () {
                    _newCatlogController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                    child: Text('SAVE'),
                    onPressed: _errorNewCatalogMsg != null
                        ? null
                        : () async {
                            await _saveCatalog();
                          }),
              ],
            );
          });
        });
  }

  Future<void> _removeCatalog(CatalogEntity catalog) async {
    await catalogDao.deleteCatalog(catalog).then((value) {
      setState(() {
        catalogs = getAllCatalogs();
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Remove Catalog ${catalog.catalog} Success"),
      ));
    }).catchError((e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Remove Catalog ${catalog.catalog} Failed"),
      ));
    });
    print(catalogs);
    Navigator.of(context).pop();
  }

  Future<void> _saveCatalog() async {
    await catalogDao
        .insertCatalog(
            CatalogEntity(null, _newCatlogController.value.text.trim()))
        .then((value) {
      if (this.mounted) {
        setState(() {
          catalogs = getAllCatalogs();
        });
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Add Catalog Success"),
      ));
    }).catchError((e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Add Catalog Failed"),
      ));
    });
    Navigator.of(context).pop();
  }

  Future<void> _editCatalog(CatalogEntity catalog) async {
    await catalogDao
        .updateCatlog(
            CatalogEntity(catalog.id, _editCatlogController.value.text.trim()))
        .then((value) {
      setState(() {
        catalogs = getAllCatalogs();
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Update Catalog Success"),
      ));
    }).catchError((e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Update Catalog Failed"),
      ));
    });
    Navigator.of(context).pop();
  }
}
