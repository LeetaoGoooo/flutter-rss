import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:rss/models/dao/catalog_dao.dart';
import 'package:rss/models/entity/catalog_entity.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/service/rssService.dart';
import 'package:rss/tools/feedParser.dart';
import 'package:rss/constants/globals.dart' as g;

class RssEditDialog extends StatefulWidget {
  final Widget avatar;
  final String title;
  final String catalog;
  final int catalogId;
  final int rssId;
  final String url;

  const RssEditDialog(
      {Key key,
      this.avatar,
      this.title,
      this.catalog,
      this.catalogId,
      this.rssId,
      this.url})
      : super(key: key);

  @override
  RssEditDialogState createState() =>
      new RssEditDialogState(avatar, title, catalog, catalogId, rssId, url);
}

class RssEditDialogState extends State<RssEditDialog> {
  final Widget avatar;
  final String title;
  final String catalog;
  final int catalogId;
  final int rssId;
  final String url;
  final _formKey = GlobalKey<FormState>();
  String _urlErrorText;
  String _nameErrorText;
  TextEditingController _urlController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  final CatalogDao catalogDao = g.catalogDao;
  int _currentSelectCatalogId;

  RssEditDialogState(this.avatar, this.title, this.catalog, this.catalogId,
      this.rssId, this.url);

  @override
  void initState() {
    super.initState();
    setState(() {
      _urlController.value = TextEditingValue(text: url);
      _nameController.value = TextEditingValue(text: title);
    });
  }

  Future<List<CatalogEntity>> getAllCatalog() async {
    List<CatalogEntity> catalogList = await catalogDao.findAllCatalogs();
    catalogList.add(CatalogEntity(-1, "All"));
    return catalogList;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(title),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: null),
        ],
      ),
      body: Container(
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: avatar),
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: TextFormField(
                        onChanged: (value) async {
                          await _validateUrl(value);
                        },
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'Url',
                          errorText: _urlErrorText,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.link,
                          ),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: TextFormField(
                        onChanged: (value) => _validateName(value),
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          errorText: _nameErrorText,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.language,
                          ),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: FutureBuilder(
                          future: getAllCatalog(),
                          builder: (context, snap) {
                            if (snap.hasData &&
                                snap.connectionState == ConnectionState.done) {
                              List<CatalogEntity> catalogs = snap.data;
                              return DropdownButtonFormField<int>(
                                value: catalogId,
                                decoration: InputDecoration(
                                    labelText: "Catalog",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
                                onChanged: (int value) {
                                  setState(() {
                                    _currentSelectCatalogId = value;
                                  });
                                },
                                items: catalogs
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e.catalog),
                                          value: e.id,
                                        ))
                                    .toList(),
                              );
                            }
                            return Align(
                              child: CircularProgressIndicator(),
                            );
                          })),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: ProgressButton(
                        defaultWidget: const Text('SAVE',
                            style: TextStyle(color: Colors.white)),
                        progressWidget: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                        color: Colors.deepPurple,
                        width: 110,
                        onPressed:
                            (_urlErrorText != null || _nameErrorText != null)
                                ? null
                                : () {
                                    _save();
                                  }),
                  )
                ],
              ))),
    );
  }

  Future<void> _validateUrl(value) async {
    FeedParser feedParser =
        new FeedParser(url: _urlController.value.text.trim().toString());
    await feedParser.parseRss().then((value) {
      setState(() {
        _urlErrorText = null;
      });
    }).catchError((e) {
      feedParser.parseAtom().then((value) {
        setState(() {
          _urlErrorText = null;
        });
      }).catchError((e) {
        setState(() {
          _urlErrorText = "Url is not accessible";
        });
      });
    });
  }

  void _validateName(value) {
    if (_nameController.value.text.trim().toString().length > 18) {
      setState(() {
        _nameErrorText = "Name is suggested less than 18 characters";
      });
    } else {
      setState(() {
        _nameErrorText = null;
      });
    }
  }

  void _save() {
    var _url = _urlController.value.text.trim();
    var _name = _nameController.value.text.trim();
    var _rssId = rssId;
    var _catalogId =
        _currentSelectCatalogId == null ? -1 : _currentSelectCatalogId;
    print("url:$_url,name:$_name,rssId:$_rssId,catalog:$_catalogId");
    RssService rssService = new RssService();
    rssService.updateRss(_rssId, _name, _url, _catalogId);
  }
}
