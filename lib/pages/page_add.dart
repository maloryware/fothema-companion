


import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/main.dart';
import 'package:universal_ble/universal_ble.dart';

import '../configuration.dart';
import '../widget/device_tile.dart';

class AddDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddDevicePageState();

}


class _AddDevicePageState extends State<AddDevicePage>{
  bool failState(){
    return noPerms || isChecking || !isBluetoothOn;
  }

  List<DeviceTile> _shownTiles = [];
  List<DeviceTile> _hiddenTiles = [];



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

        _shownTiles.clear();
        _hiddenTiles.clear();

        for(var device in devices)
          _shownTiles.add(DeviceTile(device: device, refresh: refresh));

        for(var device in hiddenDevices)
          _hiddenTiles.add(DeviceTile(device: device, refresh: refresh,));


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
            defineService();
            signalConnect();
            getConfig();
            print("Added device [$device] to connectedDevices");
          }
        }
      });

    };

    _refresh();
  }

  void refresh() async {
    setState(() {
      initState();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _shownTiles.clear();
      _hiddenTiles.clear();

    });
  }

  @override
  void initState() {
    asyncInitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(debugMode() && !forceBluetoothFunctionality()) return Center(child: Text("Debug mode enabled - Bluetooth functionality not being utilized."));

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
          SizedBox(height: 30),
          if(failState()) Expanded(child: Center(child: Text(failStateText)))
          else if(devices.isEmpty) Expanded(child: Center(child: Text("No devices detected.")))

          else Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(

                    children: [
                      for(Widget x in _shownTiles) x,
                      if(hiddenDevices.isNotEmpty)
                        ExpansionTile(
                          title: Text("Hidden devices"),
                          children: [
                            for(Widget x in _hiddenTiles) x
                          ],
                        )

                    ]
                ),
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
                      if(debugMode()) ElevatedButton(onPressed: () => print(devices), child: Text("Get list"), ),
                    ],
                  ),
                )
            )
        ],
      ),
    );
  }
}
