import 'package:flutter/material.dart';
import 'package:fothema_companion/pages/page_add.dart';


class Page {
  final IconData icon;
  final Widget widget;
  Page(this.icon, this.widget);
}


class Pages {
  var gestures = Page(Icons.waving_hand, Placeholder());
  var modules = Page(Icons.account_tree_sharp, Placeholder());
  var add  = Page(Icons.add, AddDevicePage());
  var mirror = Page(Icons.rectangle_outlined, Placeholder());
  var settings = Page(Icons.settings, Placeholder());
}


//* defines the home page (index)
const int homePage = 2;

