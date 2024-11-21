import 'package:flutter/material.dart';
import 'package:fothema_companion/pages/page_add.dart';
import 'package:fothema_companion/pages/page_gestures.dart';
import 'package:fothema_companion/pages/page_mirror.dart';
import 'package:fothema_companion/pages/page_modules.dart';
import 'package:fothema_companion/pages/page_settings.dart';


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

