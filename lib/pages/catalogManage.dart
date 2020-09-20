/// file        : catalogManage.dart
/// descrption  :  分类管理页面
/// date        : 2020/09/06 20:11:44
/// author      : Leetao
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rss/compents/rssCardWidget.dart';
import 'package:rss/events/rssCardEvent.dart';
import 'package:rss/models/entity/rsscard_entity.dart';
import 'package:rss/pages/catalogSetting.dart';
import 'package:rss/service/catalogService.dart';
import 'package:rss/tools/globalEventBus.dart';

class CatalogManage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CatalogManageStateWidget();
}

class CatalogManageStateWidget extends State<CatalogManage> {
  List<RssCardEntity> rssCardList = [];
  bool showProgressBar = true;
  final CatalogService catalogService = new CatalogService();
  final GlobalEventBus eventBus = new GlobalEventBus();

  @override
  void initState() {
    super.initState();
    catalogService.getAllRssCard();
    eventBus.event.on<RssCardEvent>().listen((events) {
      addRssCard(events.rssCard);
    });
  }

  addRssCard(RssCardEntity rssCard) {
    if (this.mounted && !rssCardList.contains(rssCard)) {
      setState(() {
          rssCardList.add(rssCard);
        showProgressBar = false;
      });
    }
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
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (_) {
                    return new CatalogSetting();
                  }));
                })
          ],
        ),
        body: _buildCardList());
  }

  Widget _buildCardList() {
    return Stack(
      children: [
        Visibility(visible: showProgressBar, child: LinearProgressIndicator()),
        RefreshIndicator(
          child: GridView.builder(
              itemCount: rssCardList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                RssCardEntity rssCard = rssCardList[index];
                return RssCard(
                  avatar: rssCard.avatar,
                  title: rssCard.title,
                  subTitle: rssCard.subTitle,
                  all: rssCard.all,
                  read: rssCard.read,
                  unread: rssCard.unread,
                  rssId: rssCard.rssId,
                  catalogId: rssCard.catalogId,
                  url: rssCard.url,
                  voidCallback: refresh,
                );
              }),
          onRefresh: refresh,
        )
      ],
    );
  }

  Future<void> refresh() async {
    await catalogService.getAllRssCard();
  }
}
