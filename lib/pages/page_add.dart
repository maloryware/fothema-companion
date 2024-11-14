

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

    setState(() {


      UniversalBle.onAvailabilityChange = (state) async {
        switch(state){

          case AvailabilityState.unknown:
          case AvailabilityState.resetting:
          case AvailabilityState.unsupported:
          case AvailabilityState.unauthorized:
            await isBTPermissionGiven();
            _noPerms = true;
          case AvailabilityState.poweredOff:
            _isBluetoothOn = false;
            _isChecking = false;
          case AvailabilityState.poweredOn:
            _isBluetoothOn = true;
            _isChecking = false;
        }
      };

      UniversalBle.onScanResult = (device) {
        devices.add(device);
      };


    });
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

    return Scaffold(

      body: Stack(
          children: [
            Column(
              children: [
                  for(var device in devices)
                    ExpansionTile(
                      leading: Icon(Icons.bluetooth),
                      title: Text(device.toString()),
                      children: [
                        ElevatedButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.play_arrow_outlined),
                          label: Text("Connect")
                        )]
                      )]),
            Padding(padding: EdgeInsets.only(top: 40)),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Align(alignment: Alignment.bottomCenter, child: ElevatedButton(onPressed: UniversalBle.startScan, child: Text("Scan"), )),
            ),
          ]


      ),

    );
  }

}