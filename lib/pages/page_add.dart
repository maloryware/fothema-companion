

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage>{

  var _noPerms = false;
  var _isChecking = false;
  var _isBluetoothOn = false;
  String failStateText = "";
  List<BleDevice> devices = [];

  bool failState(){
    return _noPerms || _isChecking || !_isBluetoothOn;
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

  void asyncInitState() async {

    await isBTPermissionGiven();
      UniversalBle.onAvailabilityChange = (state) {
          setState(() async {
            switch (state) {
              case AvailabilityState.unknown:
              case AvailabilityState.unsupported:
              case AvailabilityState.unauthorized:
                _noPerms = true;
              case AvailabilityState.poweredOff:
                _isBluetoothOn = false;
                _isChecking = false;
                _noPerms = false;
              case AvailabilityState.resetting:
                asyncInitState();
              case AvailabilityState.poweredOn:
                _isBluetoothOn = true;
                _isChecking = false;
                _noPerms = false;

            }
          });
      };

      UniversalBle.onScanResult = (device) {
        setState(() {
          devices.add(device);
        });
      };


    }


  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  @override
  Widget build(BuildContext context) {


    if(failState()){
      if (_noPerms) failStateText = "Please provide bluetooth permissions.";
      else if (_isChecking) failStateText = "Checking...";
      else if (!_isBluetoothOn) failStateText = "Bluetooth disabled.";
      return Center(child: Text(failStateText));
    }

    return Builder(
      builder: (context) {
        return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                        for(var device in devices)
                          ExpansionTile(
                            leading: Icon(Icons.bluetooth),
                            title: Text(device.name != null && device.name.toString().isNotEmpty ? device.name.toString() : device.deviceId),
                            subtitle: Text(device.rssi.toString()),
                            //* Contents of the expanded item go below
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(alignment: Alignment.centerLeft, child: Text(device.isPaired! ? "Paired" : "Not paired" )),
                              ),
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.only(left: 5)),
                                  ElevatedButton.icon(
                                    onPressed: null,
                                    icon: Icon(Icons.play_arrow_outlined),
                                    label: Text("Connect")
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: null,
                                    icon: Icon(Icons.connect_without_contact),
                                    label: Text("Pair")
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => print(device.toString()),
                                    icon: Icon(Icons.bug_report),
                                    label: Text("Print device info")
                                  ),
                                ]
                              ),
                            ]
                          )
                    ]
                  ),
                ),
               ConstrainedBox(
                   constraints: const BoxConstraints(maxHeight: 5, minHeight: 5),
                   child: SizedBox(width: 1, height: 1,)),
               ConstrainedBox(constraints: const BoxConstraints(minHeight: 10),
               child: Padding(
                 padding: const EdgeInsets.only(bottom: 25.0),
                 child: ElevatedButton(onPressed: UniversalBle.startScan, child: Text("Scan"), ),
               )),
              ]
        );
      }
    );
  }

}