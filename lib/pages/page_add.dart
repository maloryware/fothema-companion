


import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/main.dart';
import 'package:universal_ble/universal_ble.dart';

import '../widget/device_tile.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage>{
  bool failState(){
    return noPerms || isChecking || !isBluetoothOn;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(debugMode) return Center(child: Text("Debug mode enabled - Bluetooth functionality not being utilized."));

    if(failState()) {
      if (noPerms)
        failStateText = "Please provide bluetooth permissions.";
      else if (isChecking)
        failStateText = "Checking...";
      else if (!isBluetoothOn) failStateText = "Bluetooth disabled.";
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(failState()) Expanded(child: Center(child: Text(failStateText)))
          else if(devices.isEmpty) Expanded(child: Center(child: Text("No devices detected.")))

          else Expanded(
            child: ListView(
                children: [
                  for(var device in devices)
                    DeviceTile(device: device, title: device.name != null && device.name.toString().isNotEmpty ? device.name.toString() : device.deviceId),
                  if(hiddenDevices.isNotEmpty)
                    ExpansionTile(
                      title: Text("Hidden devices"),
                      children: [
                        for(var device in hiddenDevices)
                          DeviceTile(device: device, title: "Hidden devices")
                      ],
                    )

                ]
            ),
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 5, minHeight: 5),
              child: SizedBox(width: 1, height: 1,)
          ),
          if(!failState())
          ConstrainedBox(constraints: const BoxConstraints(minHeight: 10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: UniversalBle.startScan, child: Text("Scan"), ),
                    ElevatedButton(onPressed: UniversalBle.stopScan, child: Text("Stop"), ),
                    ElevatedButton(onPressed: () => setState(devices.clear), child: Text("Clear"), ),
                    ElevatedButton(onPressed: () => print(devices), child: Text("Get list"), ),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}