import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rss/pages/homePage.dart';

import 'package:rss/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/database.dart';
import 'constants/globals.dart' as g;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final migration4to5 = Migration(4, 5, (database) async {
  //   await database.execute('DELETE FROM rss');
  // });
  await $FloorAppDatabase
      .databaseBuilder('rss-v001.db')
      // .addMigrations([migration4to5])
      .build()
      .then((database) {
    g.catalogDao = database.catalogDao;
    g.rssDao = database.rssDao;
    g.rss2catalogDao = database.rss2catalogDao;
    g.feedsDao = database.feedsDao;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();

  /// sp初始化
  await SpUtil.getInstance();
  runApp(PeachRssApp());
}

class PeachRssApp extends StatelessWidget {
  final ThemeData theme;

  PeachRssApp({this.theme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(builder: (pcontext, provider, __) {
          print("theme change...");
          return provider.getThemeMode() == ThemeMode.dark
              ? MaterialApp(
                  theme: provider.getTheme(isDarkMode: true),
                  title: 'RSS',
                  home: HomePage())
              : MaterialApp(
                  theme: provider.getTheme(),
                  title: 'RSS',
                  home: HomePage());
        }));
  }
}