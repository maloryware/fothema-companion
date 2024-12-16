import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:universal_ble/universal_ble.dart';

class MirrorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MirrorPageState();
}

class _MirrorPageState extends State<MirrorPage> {



  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return (!connected) ? Center(child: Text("Not connected")) :
      Scaffold(
      body: ListView(
        children: [

          for(BleDevice device in connectedDevices)
            Column(
              children: [
                _InfoRow(title: "Device Name", data: device.name ?? "null"),
                _InfoRow(title: "Device ID", data: device.deviceId),
                _InfoRow(title: "Service UUIDs", data: device.services.toString()),
                _InfoRow(title: "RSSI (Connectivity)", data: device.rssi.toString()),
                _InfoRow(title: "Manufacturer Data List", data: device.manufacturerDataList.toString()),
              ],
            ),
          ElevatedButton(
            onPressed: reload,
            child: Text("Reload mirror!")
          )
        ],
      ),
    );


  }
}

class _InfoRow extends StatelessWidget {
  final String data;
  final String title;

  _InfoRow({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Row(
      children: [
        Text(title),
        Spacer(),
        Flexible(child: Text(data))
      ],
    );
  }

}