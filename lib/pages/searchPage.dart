import 'package:backdrop/app_bar.dart';
import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:rss/compents/articleHeroWidget.dart';
import 'package:rss/events/filterFeedEvent.dart';
import 'package:rss/models/entity/feeds_entity.dart';
import 'package:rss/service/feedService.dart';
import 'package:rss/tools/globalEventBus.dart';

class SearchPage extends StatefulWidget {
  @override
  SearchStatePage createState() => SearchStatePage();
}

class SearchStatePage extends State<SearchPage> {
  final TextEditingController _controller = new TextEditingController();
  bool _titleSwitch = true;
  bool _contentSwitch = true;
  List<FeedsEntity> filterFeedList = [];
  final FeedService feedService = new FeedService();
  final GlobalEventBus eventBus = new GlobalEventBus();

  @override
  void initState() {
    super.initState();
    eventBus.event.on<FilterFeedEvent>().listen((event) {
      addFeed(event.feed);
    });
  }

  addFeed(FeedsEntity feed) {
    if (this.mounted) {
      setState(() {
        filterFeedList.add(feed);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BackdropScaffold(
        appBar: BackdropAppBar(
            backgroundColor: Theme.of(context).appBarTheme.color,
            title: Text("Feeds Filter")),
        backLayer: Container(
          color: Theme.of(context).appBarTheme.color,
          child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                      prefixStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 10.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Filters(Choice one at least)",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                ListTile(
                  title: Text(
                    "Title",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Switch(
                      value: _titleSwitch,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        if (!value && !_contentSwitch) {
                          return;
                        }
                        setState(() {
                          _titleSwitch = value;
                        });
                      }),
                ),
                ListTile(
                  title: Text(
                    "Content",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Switch(
                      value: _contentSwitch,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        if (!value && !_titleSwitch) {
                          return;
                        }
                        setState(() {
                          _contentSwitch = value;
                        });
                      }),
                ),
                ProgressButton(
                  defaultWidget: const Text(
                    'SEARCH',
                    style: TextStyle(color: Colors.white),
                  ),
                  progressWidget: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  color: Theme.of(context).buttonTheme.colorScheme.primary,
                  width: 110,
                  onPressed: () async {
                    setState(() {
                      filterFeedList = [];
                    });
                    await Future.delayed(Duration(milliseconds: 3000));
                    await feedService.getFilterFeeds(
                        _controller.value.text.trim(),
                        titleOnly: _titleSwitch,
                        contentOnly: _contentSwitch);
                  },
                )
              ])),
        ),
        subHeader: BackdropSubHeader(
          title: Text("Filter Results"),
        ),
        frontLayer: Container(
            child: ListView.builder(
          itemCount: filterFeedList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext buildContext, int index) {
            var feed = filterFeedList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ArticleHeroWidget(
                      content: feed.content,
                      link: feed.url,
                      author: feed.author,
                      pubDate: feed.published,
                      title: feed.title,
                      rssId: feed.rssId,
                      catalogId: feed.catalogId);
                }));
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  title: Text(feed.title),
                ),
              ),
            );
          },
        )),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.home)),
      ),
    );
  }
}
