

import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fothema_companion/pages/page_add.dart';
import 'package:fothema_companion/pages/page_shop.dart';
import 'package:fothema_companion/pages/page_mirror.dart';
import 'package:fothema_companion/pages/page_modules.dart';
import 'package:fothema_companion/pages/page_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_ble/universal_ble.dart';

import 'bluetooth.dart';
import 'module.dart';

//* boilerplate defs *

typedef JsonObj = Map<String, dynamic>;

class Page {
  final IconData icon;
  final Widget widget;
  Page(this.icon, this.widget);
}

class Pages {
  var shop = Page(Icons.shop, ShopPage());
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

    await isBTPermissionGiven();

    UniversalBle.onAvailabilityChange = (state) {
      setState(() async {
        switch (state) {
          case AvailabilityState.resetting:
          case AvailabilityState.unknown:
          case AvailabilityState.unsupported:
          case AvailabilityState.unauthorized:
            isChecking = true;
          case AvailabilityState.poweredOff:
            isBluetoothOn = false;
            isChecking = false;
            noPerms = false;
          case AvailabilityState.poweredOn:
            isBluetoothOn = true;
            isChecking = false;
            noPerms = false;
        }
        if(lastState != state) print(state);
        lastState = state;
      });
    };

    UniversalBle.onScanResult = (device) {
      setState(() {
        bool willAdd = true;
        List<BleDevice> selectedList = [];

        selectedList = device.name == null ? hiddenDevices : devices;

        if(selectedList.isEmpty) {
          print("Adding device $device");
          selectedList.add(device);
          willAdd = false;
        }

        else for(BleDevice presentDevice in selectedList){
          if(presentDevice.deviceId == device.deviceId) {
            willAdd = false;
            break;
          }
        }
        if(willAdd) {
          selectedList.add(device);
        }

        selectedList.sort((a, b) {
          var x = b.rssi!.compareTo(a.rssi as num);
          return x;
        });
      });
    };



    UniversalBle.onConnectionChange = (callbackDeviceId, didConnect, err) {
      setState(() async {
        print("Connection state changed. DeviceId: $callbackDeviceId, Connected: $didConnect, Err: $err");

        connected = didConnect;
        deviceId = callbackDeviceId;

        for (BleDevice device in devices){
          if(device.deviceId == deviceId && !connected && connectedDevices.contains(device)){
            connectedDevices.remove(device);
            print("Removed device [$device] from connectedDevices");
          }
          if(device.deviceId == deviceId && connected && !connectedDevices.contains(device)){
            connectedDevices.add(device);
            availableServices = await UniversalBle.discoverServices(deviceId);
            getConfig();
            defineService();
            print("Added device [$device] to connectedDevices");
          }
        }
      });

    };
  }
  @override
  void initState() {
    if(!config.exists) getConfig();
    activeModules = [];
    inactiveModules = [];
    for(MMModule mod in config.modules){
      mod.isEnabled() && mod.title != "alert"
          ? activeModules.add(mod)
          : inactiveModules.add(mod);
    }

    super.initState();
    asyncInitState();
  }

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
                          Pages().shop.widget,
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
                  TabItem(icon: Pages().shop.icon),
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
