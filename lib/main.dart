

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fothema_companion/pages/page_add.dart';
import 'package:fothema_companion/pages/page_gestures.dart';
import 'package:fothema_companion/pages/page_mirror.dart';
import 'package:fothema_companion/pages/page_modules.dart';
import 'package:fothema_companion/pages/page_settings.dart';

/// boilerplate defs *

typedef JsonObj = Map<String, dynamic>;
class Page {
  final IconData icon;
  final Widget widget;
  Page(this.icon, this.widget);
}
class Pages {
  var gestures = Page(Icons.waving_hand, GesturesPage());
  var modules = Page(Icons.account_tree_sharp, ModulesPage());
  var add  = Page(Icons.add, AddDevicePage());
  var mirror = Page(Icons.rectangle_outlined, MirrorPage());
  var settings = Page(Icons.settings, SettingsPage());
}
//* defines the home page (index)
const int homePage = 2;

/// end boilerplate defs *

void main() {
  runApp(Home());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        home: DefaultTabController(
          initialIndex: homePage,
          length: 5,
          child: Scaffold(
            body: Column(
              children: [
                const Divider(),
                Expanded(
                    child: TabBarView(
                        children: [
                          Pages().gestures.widget,
                          Pages().modules.widget,
                          Pages().add.widget,
                          Pages().mirror.widget,
                          Pages().settings.widget,
                        ]
                    )
                )
              ],
            ),
            bottomNavigationBar: ConvexAppBar.badge(
              //* optional badge args for each of the badges
              //* takes Strgestures, Icogesturesta, Color, and Widget
                const<int, dynamic>{},
                style: TabStyle.reactCircle,
                backgroundColor: Color(0xffa1337f),
                items: <TabItem>[
                  TabItem(icon: Pages().gestures.icon),
                  TabItem(icon: Pages().modules.icon),
                  TabItem(icon: Pages().add.icon),
                  TabItem(icon: Pages().mirror.icon),
                  TabItem(icon: Pages().settings.icon)
                ]
            ),
          ),
        )
    );
  }

}
