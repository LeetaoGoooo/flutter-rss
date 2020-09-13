import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rss/comm/colors.dart';
import 'package:rss/comm/contants.dart';
import 'package:rss/comm/styles.dart';

extension ThemeModeExtension on ThemeMode {
  String get value => ['System', 'Light', 'Dark'][index];
}

class ThemeProvider extends ChangeNotifier {
  void syncTheme() {
    final String theme = SpUtil.getString(Constant.theme);
    if (theme.isNotEmpty && theme != ThemeMode.system.value) {
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
    SpUtil.putString(Constant.theme, themeMode.value);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final String theme = SpUtil.getString(Constant.theme);
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
      errorColor: isDarkMode ? Colours.dark_red : Colours.red,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      backgroundColor: isDarkMode ? Colors.black54 : Colors.white,
      primaryColor: isDarkMode ? Colours.dark_app_primary : Colours.app_primary,
      accentColor: isDarkMode ? Colours.dark_app_primary : Colours.app_primary,
      // Tab指示器颜色
      indicatorColor: isDarkMode ? Colours.dark_app_main : Colors.pinkAccent,
      tabBarTheme:
          TabBarTheme(labelColor:  Colors.white),
      // 页面背景色
      scaffoldBackgroundColor: isDarkMode ? Colors.black54 : Colors.white,
      // 主要用于Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      // 文字选择色（输入框复制粘贴菜单）
      textSelectionColor: Colours.app_main.withAlpha(70),
      textSelectionHandleColor: Colours.app_main,
      textTheme: TextTheme(
        // TextField输入文字颜色
        subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        subtitle2:
            isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
          elevation: 0.0,
          textTheme: TextTheme(title: TextStyle(color: Colors.white)),
          color: isDarkMode ? Colours.dark_bg_color : Colors.purple,
          iconTheme: IconThemeData(color: Colors.white),
          brightness: isDarkMode ? Brightness.dark : Brightness.light),
      bottomAppBarTheme: BottomAppBarTheme(
        color:isDarkMode ? Colours.dark_bg_color : Colors.purple,
        ),
    
      dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
          space: 0.6,
          thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      // pageTransitionsTheme: NoTransitionsOnWeb(),
    );
  }
}
