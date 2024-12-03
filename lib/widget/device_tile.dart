
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

import '../bluetooth.dart';

class DeviceTile extends StatefulWidget{

  final BleDevice device;
  final String title;
  DeviceTile({required this.device, required this.title});

  @override
  State<StatefulWidget> createState() => DeviceTileState();
}

class DeviceTileState extends State<DeviceTile>{

  var device;

  @override
  void initState() {
    device = widget.device;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpansionTile(leading: Icon(Icons.bluetooth),
      title: Text(widget.title, style: connectedDevices.contains(device) ? TextStyle(color: Colors.green) : TextStyle()),
      subtitle: Text("Connectivity: ${145 + device.rssi! < 100 ? 145 + device.rssi! : 100}%"),
      children: [

        Padding(
        padding: const EdgeInsets.only(left: 5),
          child: Align(alignment: Alignment.centerLeft, child: Text(
            connectedDevices.contains(device) ? "Connected" :
              device.isPaired! ? "Paired" : "Not paired" )
            )),
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
        )
      ]);
  }

}