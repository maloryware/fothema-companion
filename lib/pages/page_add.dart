

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}


class _AddDevicePageState extends State<AddDevicePage>{


  bool failState(){
    return noPerms || isChecking || !isBluetoothOn;
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
    super.initState();
    asyncInitState();
  }

  @override
  Widget build(BuildContext context) {

    if(failState()){
      if (noPerms) failStateText = "Please provide bluetooth permissions.";
      else if (isChecking) failStateText = "Checking...";
      else if (!isBluetoothOn) failStateText = "Bluetooth disabled.";
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: Text(failStateText))),
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 5, minHeight: 5),
                child: SizedBox(width: 1, height: 1,)
            ),
            if(!isBluetoothOn && !isChecking && !noPerms)
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

    return Builder(
      builder: (context) {
        if(devices.isEmpty && hiddenDevices.isEmpty) return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: Text("No devices detected."))),
              ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 5, minHeight: 5),
                  child: SizedBox(width: 1, height: 1,)
              ),
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
        else return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                        for(var device in devices)
                          ExpansionTile(
                            leading: Icon(Icons.bluetooth),
                            title: Text(
                                device.name != null && device.name.toString().isNotEmpty ? device.name.toString() : device.deviceId,
                                style: connectedDevices.contains(device) ? TextStyle(color: Colors.green) : TextStyle()),
                            subtitle: Text("Connectivity: ${145 + device.rssi! < 100 ? 145 + device.rssi! : 100}%"),

                            //* Contents of the expanded item go below
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Align(alignment: Alignment.centerLeft, child: Text(
                                    connectedDevices.contains(device) ? "Connected" :
                                    device.isPaired! ? "Paired" : "Not paired" )
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.only(left: 5)),
                                  ElevatedButton.icon(
                                    onPressed: connectedDevices.contains(device) ? null : () => UniversalBle.connect(device.deviceId),
                                    icon: Icon(Icons.play_arrow_outlined),
                                    label: Text("Connect")
                                  ),

                                  ElevatedButton.icon(
                                    onPressed:  device.isPaired! ? null : () => UniversalBle.pair(device.deviceId),
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
                          ),
                      if(hiddenDevices.isNotEmpty)
                        ExpansionTile(
                          title: Text("Hidden devices"),
                          children: [
                            for(var device in hiddenDevices)
                              ExpansionTile(
                                  leading: Icon(Icons.bluetooth),
                                  title: Text(device.name != null && device.name.toString().isNotEmpty ? device.name.toString() : device.deviceId),
                                  subtitle: Text("Connectivity: ${145 + device.rssi! < 100 ? 145 + device.rssi! : 100}%"),
                                  //* Contents of the expanded item go below
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Align(alignment: Alignment.centerLeft, child: Text(
                                          connectedDevices.contains(device) ? "Connected" :
                                          device.isPaired! ? "Paired" : "Not paired" )
                                      ),
                                    ),
                                    Row(
                                        children: [
                                          Padding(padding: EdgeInsets.only(left: 5)),
                                          ElevatedButton.icon(
                                              onPressed: connectedDevices.contains(device) ? null : () => UniversalBle.connect(device.deviceId),
                                              icon: Icon(Icons.play_arrow_outlined),
                                              label: Text("Connect")
                                          ),

                                          ElevatedButton.icon(
                                              onPressed:  device.isPaired! ? null : () => UniversalBle.pair(device.deviceId),
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
                              ),
                          ],
                        )

                    ]
                  ),
                ),
                 ConstrainedBox(
                     constraints: const BoxConstraints(maxHeight: 5, minHeight: 5),
                     child: SizedBox(width: 1, height: 1,)
                 ),
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
                       ElevatedButton(onPressed: connectedDevices.isEmpty ? null : () => UniversalBle.disconnect(connectedDevices.first.deviceId), child: Text("Force Disconnect"), )
                     ],
                   ),
               ))
              ]
        );
      }
    );
  }

}