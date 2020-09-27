import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss/constants/globals.dart';
import 'package:rss/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss/constants/globals.dart' as g;

class SettingWidgetPage extends StatefulWidget {
  @override
  SettingStateWidget createState() => SettingStateWidget();
}

class SettingStateWidget extends State<SettingWidgetPage> {
  bool _switchValue = false;
  bool _onlyWifi = true;
  // final CacheTool cacheTool = new CacheTool();
  Icon _darkModeIcon = Icon(Icons.wb_sunny);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // String cacheSize = "0M";

  @override
  void initState() {
    super.initState();
    _initThemeMode();
    // loadCacheSize();
  }

  // Future<void> loadCacheSize() async {
  //   var _cacheSize = await cacheTool.loadApplicationCache();
  //   print("当前app缓存大小:$_cacheSize");
  //   setState(() {
  //     cacheSize = _cacheSize;
  //   });
  // }

  void _initThemeMode() async {
    final SharedPreferences prefs = await _prefs;
    ThemeMode themeMode = ThemeMode.system;
    if (prefs.containsKey(g.THEME_MODE)) {
      if (prefs.getString(g.THEME_MODE) == g.THEME_DARK_MODE) {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.light;
      }
      if (themeMode == ThemeMode.dark) {
        setState(() {
          _switchValue = true;
          _darkModeIcon = Icon(Icons.brightness_2);
        });
      } else {
        setState(() {
          _switchValue = false;
          _darkModeIcon = Icon(Icons.wb_sunny);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings",style: Theme.of(context).appBarTheme.textTheme.subtitle1),
      ),
      body: Container(
          child: Column(children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
            child: Text(
              "SYNCING",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.timer),
          title: Text("Keep Read Items"),
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
              onChanged: (value) async {
                ThemeMode themeMode = value ? ThemeMode.dark : ThemeMode.light;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTheme(themeMode);
                final SharedPreferences prefs = await _prefs;
                prefs.setString(
                    THEME_MODE,
                    themeMode == ThemeMode.dark
                        ? THEME_DARK_MODE
                        : THEME_LIGHT_MODE);
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
}
