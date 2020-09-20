import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss/provider/theme_provider.dart';

class SettingWidgetPage extends StatefulWidget {
  @override
  SettingStateWidget createState() => SettingStateWidget();
}

class SettingStateWidget extends State<SettingWidgetPage> {
  bool _switchValue = false;
  bool _onlyWifi = true;
  bool _refreshOnOpen = true;
  Icon _darkModeIcon = Icon(Icons.wb_sunny);

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
          trailing: Switch(value: _onlyWifi, onChanged: null),
        ),
        ListTile(
          leading: Icon(Icons.lock_open),
          title: Text("Refresh On Open"),
          trailing: Switch(value: _refreshOnOpen, onChanged: null),
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
          subtitle: Text("4 M"),
          trailing: IconButton(icon: Icon(Icons.delete), onPressed: null),
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
                ListTile(
          leading: Icon(Icons.feedback),
          title: Text("FeedBack")
        ),
                        ListTile(
          leading: Icon(Icons.copyright),
          title: Text("Version"),
          subtitle: Text("1.0.0"),
        ),
      ])),
    );
  }
}
