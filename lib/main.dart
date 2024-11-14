
import 'dart:async';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fothema_companion/consts.dart';




void main() {


  runApp(Home());

}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {




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
