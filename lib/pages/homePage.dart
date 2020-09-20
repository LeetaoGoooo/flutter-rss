import 'package:flutter/material.dart';
import 'package:rss/pages/catalogManage.dart';

import 'package:rss/pages/searchPage.dart';
import 'package:rss/pages/settingWidget.dart';

import 'homeWidget.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomeStatePage();
}

class HomeStatePage extends State<HomePage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedPageIndex = index;
        });
      },
      children: <Widget>[
        HomeWidgetPage(),
        CatalogManage(),
        SearchPage(),
        SettingWidgetPage()
      ],
    );
  }

  void bottomTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text("Home")),
            BottomNavigationBarItem(
              icon: Icon(Icons.widgets),
              title: Text("Catalogs"),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text("Seach")),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text("User")),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.explore), title: Text("Explore")),
          ],
          onTap: (value) {
            bottomTapped(value);
          }),
    );
  }
}
