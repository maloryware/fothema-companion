

import 'dart:async';

import 'package:flutter/cupertino.dart';
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

  void fetchDevices() async {
    setState(() {

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

    if(_isChecking)

    if(!_isBluetoothOn) {
      failStateText = "Bluetooth is not enabled";
    }

    return ListView(

    );
  }

}