import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss/models/dao/rss_dao.dart';
import 'package:rss/models/entity/rss_entity.dart';
import 'package:rss/constants/globals.dart' as g;
import 'package:rss/shared/feedNotifier.dart';
import 'package:rss/shared/rssNotifier.dart';

class RssChipWidget extends StatefulWidget {

  RssChipWidget({Key key}) : super(key: key);

  @override
  RssChipStateWidget createState() {
    return RssChipStateWidget();
  }
}

class RssChipStateWidget extends State<RssChipWidget> {
  final RssDao rssDao = g.rssDao;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  RssEntity selectedRss;

  RssChipStateWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<RssNotifer>(builder: (context, notifier, child) {
      print("rss length:${notifier.currentRssList.length}");
      List<RssEntity> rssEntityList = notifier.currentRssList;
      return Container(
          height: 60,
          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: ListView.builder(
            itemCount: rssEntityList.length,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              RssEntity rssEntity = rssEntityList[index];
              return RawChip(
                avatar: (selectedRss == null || selectedRss.id != rssEntity.id)
                    ? null
                    : CircleAvatar(),
                selected:
                    (selectedRss == null || selectedRss.id != rssEntity.id)
                        ? false
                        : true,
                label: Text(rssEntity.title),
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                selectedShadowColor:
                    Theme.of(context).chipTheme.selectedShadowColor,
                deleteIcon: Icon(Icons.highlight_off,
                    color: Theme.of(context).chipTheme.deleteIconColor,
                    size: 18),
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
                    Provider.of<FeedNotifier>(context,listen: false).selectRss(rssEntity,value);
                  }
                },
              );
            }
          ));
    });
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
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(
                      "dismiss ${rssEntity.title} success!",
                    ),
                    behavior: SnackBarBehavior.floating,
                  ));
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
