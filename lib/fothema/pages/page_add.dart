

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fothema_companion/fothema/bluetooth.dart';
import 'package:fothema_companion/fothema/main.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage>{

  var _isChecking = true;
  var _isBluetoothOn = false;
  String failStateText = "";
  List<Object> devices = [];

  bool failState(){
    return _isChecking || !_isBluetoothOn;
  }

  void fetchDevices() async {
    setState(() {
      var myDevices = bleman.discoverDevices.listen((device) {
        devices.add(device);
      });
    });
  }

  void setBluetoothVal(bool val){
    setState(() {
      _isChecking = false;
      _isBluetoothOn = val;
    });
  }

  @override
  void initState() {
    super.initState();
    const MethodChannel("method_channel").invokeMethod("permit");
    bleman.isBluetoothOn().then(setBluetoothVal);
  }

  @override
  Widget build(BuildContext context) {

    if(_isChecking) {
      failStateText = "Please hold";
    }

    if(!_isBluetoothOn) {
      failStateText = "Bluetooth is not enabled";
    }

    if(failState()){
      return Center(child: Text(failStateText));
    }

    return ListView(
      children: [

        for(var device in devices)
          ExpansionTile(
            leading: Icon(Icons.bluetooth),
            title: Text(device.toString()),
            children: [
              ElevatedButton.icon(onPressed: null, icon: Icon(Icons.play_arrow_outlined), label: Text("Connect"))
            ],
          )


      ]
    );
  }

}