

import 'dart:io' show Platform;

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fothema_companion/pages/page_add.dart';
import 'package:fothema_companion/pages/page_info.dart';
import 'package:fothema_companion/pages/page_device.dart';
import 'package:fothema_companion/pages/page_modules.dart';
import 'package:fothema_companion/pages/page_settings.dart';
import 'package:fothema_companion/widget/init.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:universal_ble/universal_ble.dart';

import 'bluetooth.dart';

//* boilerplate defs *

typedef JsonObj = Map<String, dynamic>;

class Page {
  final IconData icon;
  final Widget widget;
  Page(this.icon, this.widget);
}

class Pages {
  var info = Page(Icons.question_mark, InfoPage());
  var modules = Page(Icons.account_tree_sharp, ModulesPage());
  var add  = Page(Icons.add, AddDevicePage());
  var mirror = Page(Icons.perm_device_information_rounded, MirrorPage());
  var settings = Page(Icons.settings, SettingsPage());
}
//* defines the home page (index)
const int homePage = 2;


/// end boilerplate defs *

void main() async {
  // oh it's idempotent? fuck you then. get ran 80000 times
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Home());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
}

Future<bool> isBTPermissionGiven() async {
  if (Platform.isAndroid) {
    var isAndroidS = true;
    if (isAndroidS) {
      if (await Permission.bluetoothScan.isGranted) {
        return true;
      } else {
        var response = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect
        ].request();
        return response[Permission.bluetoothScan]?.isGranted == true &&
            response[Permission.bluetoothConnect]?.isGranted == true;
      }
    }
  }
  return false;
}

//* end boilerplate defs *


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  void asyncInitState() async {
    relistModules();
  }

  @override
  void initState() {

    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
    asyncInitState();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(

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
                            Pages().info.widget,
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
                //* takes Strings, Icons, Color, and Widget
                  const<int, dynamic>{},
                  style: TabStyle.reactCircle,
                  backgroundColor: Color(0xffa1337f),
                  items: <TabItem>[
                    TabItem(icon: Pages().info.icon),
                    TabItem(icon: Pages().modules.icon),
                    TabItem(icon: Pages().add.icon),
                    TabItem(icon: Pages().mirror.icon),
                    TabItem(icon: Pages().settings.icon)
                  ]
              ),
            ),
          )
      ),
    );
  }

}
