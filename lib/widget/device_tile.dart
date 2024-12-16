
import 'package:flutter/material.dart';
import 'package:universal_ble/universal_ble.dart';

import '../bluetooth.dart';
import '../configuration.dart';

class DeviceTile extends StatefulWidget{

  final BleDevice device;
  final Function()? refresh;
  DeviceTile({required this.device, this.refresh});

  @override
  State<StatefulWidget> createState() => DeviceTileState();
}

class DeviceTileState extends State<DeviceTile>{

  late BleDevice _device = widget.device;
  late String _title = _device.name != null && _device.name.toString().isNotEmpty ? _device.name.toString() : _device.deviceId;
  @override
  void initState() {

    super.initState();
  }

  void refresh() {
    widget.refresh!();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpansionTile(leading: Icon(Icons.bluetooth),
      title: Text(_title, style: connectedDevices.contains(_device) ? TextStyle(color: Colors.green) : TextStyle()),
      subtitle: Text("Connectivity: ${145 + _device.rssi! < 100 ? 145 + _device.rssi! : 100}%"),
      children: [

        Padding(
        padding: const EdgeInsets.only(left: 5),
          child: Align(alignment: Alignment.centerLeft, child: Text(
            connectedDevices.contains(_device) ? "Connected" :
              _device.isPaired! ? "Paired" : "Not paired" )
            )),
        Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 5)),
              if(connected && connectedDevices.contains(_device)) ElevatedButton.icon(
                  onPressed: () => UniversalBle.disconnect(_device.deviceId),
                  icon: Icon(Icons.close_outlined),
                  label: Text("Disconnect")
              )
              else ElevatedButton.icon(
                  onPressed: () => UniversalBle.connect(_device.deviceId),
                  icon: Icon(Icons.play_arrow_outlined),
                  label: Text("Connect")
              ),

              ElevatedButton.icon(
                  onPressed:  _device.isPaired! ? null : () => UniversalBle.pair(_device.deviceId),
                  icon: Icon(Icons.connect_without_contact),
                  label: Text("Pair")
              ),
              if(debugMode()) ElevatedButton.icon(
                  onPressed: () => print(_device.toString()),
                  icon: Icon(Icons.bug_report),
                  label: Text("Print device info")
              ),

              ElevatedButton.icon(
                  onPressed: hiddenDevices.contains(_device) ? null : () => setState(() {
                    devices.remove(_device);
                    blacklist.add(_device.deviceId);
                    refresh();
                  }),
                  icon: Icon(Icons.hide_image),
                  label: Text("Hide device")
              ),
            ]
        )
      ]);
  }

}