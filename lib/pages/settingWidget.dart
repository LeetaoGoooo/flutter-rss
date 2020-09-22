import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss/constants/globals.dart';
import 'package:rss/provider/theme_provider.dart';
import 'package:rss/tools/cacheTool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingWidgetPage extends StatefulWidget {
  @override
  SettingStateWidget createState() => SettingStateWidget();
}

class SettingStateWidget extends State<SettingWidgetPage> {
  bool _switchValue = false;
  bool _onlyWifi = true;
  final CacheTool cacheTool = new CacheTool();
  Icon _darkModeIcon = Icon(Icons.wb_sunny);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String cacheSize = "0M";

  @override
  void initState() {
    super.initState();
    loadCacheSize();
  }

  Future<void> loadCacheSize() async {
    var _cacheSize = await cacheTool.loadApplicationCache();
    print("当前app缓存大小:$_cacheSize");
    setState(() {
      cacheSize = _cacheSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Container(
          child: Column(children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Text(
              "SYNC",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.timer),
          title: Text("Refresh Time"),
          subtitle: Text("4 h"),
        ),
        ListTile(
          leading: Icon(Icons.wifi),
          title: Text("Only Wi-Fi"),
          subtitle: Text("only refresh when wifi get"),
          trailing: Switch(
              value: _onlyWifi,
              onChanged: (value) async {
                print("only wifi change...$value");
                final SharedPreferences prefs = await _prefs;
                prefs.setBool(WIFI_ONLY, value);
                setState(() {
                  _onlyWifi = value;
                });
              }),
        ),
        ListTile(
          leading: _darkModeIcon,
          title: Text("Dark Model"),
          trailing: Switch(
              value: _switchValue,
              onChanged: (value) {
                ThemeMode themeMode = value ? ThemeMode.dark : ThemeMode.light;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTheme(themeMode);
                setState(() {
                  _switchValue = value;
                  _darkModeIcon =
                      value ? Icon(Icons.brightness_2) : Icon(Icons.wb_sunny);
                });
              }),
          // onTap: () {},
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Text(
              "STORAGE",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.lock_open),
          title: Text("Memory Size"),
          subtitle: Text(cacheSize),
          trailing: IconButton(icon: Icon(Icons.delete), onPressed: () async{
            await _showClearCacheConfirmDialog();
          }),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Text(
              "OTHERS",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Divider(),
        ListTile(leading: Icon(Icons.feedback), title: Text("FeedBack")),
        ListTile(
          leading: Icon(Icons.copyright),
          title: Text("Version"),
          subtitle: Text("1.0.0"),
        ),
      ])),
    );
  }

  Future<void> _showClearCacheConfirmDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cache Clean"),
          content: Text("Will you clear the cache?\nClean cache will make all your feeds delete!"),
          actions: [
            FlatButton(
              child: Text("Yes"),
              onPressed: () async {
                await cacheTool.clearApplicationCache().then((value) {
                    setState(() {
                      cacheSize = "0M";
                    });
                });
                Navigator.of(context).pop();
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
