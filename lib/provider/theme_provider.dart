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
        primaryColor: isDarkMode ? Colours.dark_app_main : Colors.white,
        accentColor: Colors.yellow[700],
        buttonColor: Colors.yellow[700],
        toggleableActiveColor: Colors.yellow[700],
        primaryColorDark:
            isDarkMode ? Colours.dark_app_main : Color(0xff303F9F),
        primaryColorLight:
            isDarkMode ? Colours.dark_app_main : Color(0xffC5CAE9),
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colors.grey : Colors.orange,
        // 页面背景色
        scaffoldBackgroundColor:
            isDarkMode ? Colours.dark_bg_color : Colors.white,
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
            
            textTheme: TextTheme(
                subtitle1:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            elevation: 0.0,
            color: isDarkMode ? Colors.black : Colors.white,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            
            actionsIconTheme:
                IconThemeData(color: isDarkMode ? Colors.white : Colors.black)),
        tabBarTheme: TabBarTheme(
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: isDarkMode ? Colors.white : Colors.grey,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: Colors.yellow[700]),
        ),
        dividerTheme: DividerThemeData(
            color: isDarkMode ? Colours.dark_line : Colours.line,
            space: 0.6,
            thickness: 0.6),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: isDarkMode? Colors.black : Colors.white,
          selectedIconTheme: IconThemeData(color:isDarkMode ? Colors.yellow[700] : Colors.black),
          unselectedIconTheme: IconThemeData(color:Colors.grey)
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white:Colors.black),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.yellow[700])
        // pageTransitionsTheme: NoTransitionsOnWeb(),
        );
  }
}
