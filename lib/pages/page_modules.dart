import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:universal_ble/universal_ble.dart';

class ModulesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModulesPageState();

}

class _ModulesPageState extends State<ModulesPage> {


  void asyncInitState() async {

    UniversalBle.onConnectionChange = (deviceId, didConnect, err) {
      setState(() async {

        if(didConnect){
          connected = didConnect;
          getConfig();
          availableServices = await UniversalBle.discoverServices(deviceId);
        }

      });
    };

    UniversalBle.onValueChange = (deviceId, characteristicId, value){
      print("Characteristic value changed:\n$deviceId,\n$characteristicId,\n$value");

    };

    UniversalBle.onAvailabilityChange = (state) {
      setState(() async {
        if(lastState != state) print(state);
        lastState = state;
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

    return !connected ? Container(alignment: Alignment.center, child: Text("Not connected.")):

    Column(
      children: [

        ExpansionTile(title: Text("Active"),
          childrenPadding: EdgeInsets.all(8.0),
          children: [

            if(activeModules.isEmpty) Text("No active modules.", style: TextStyle(color: Colors.grey))
          ],
          // list active modules from config
        ),
        ExpansionTile(title: Text("Available"),
          childrenPadding: EdgeInsets.all(8.0),
          children: [
            if(inactiveModules.isEmpty) Text("No inactive modules.", style: TextStyle(color: Colors.grey))
          ],
          // list inactive modules from config
        ),

        ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
          ElevatedButton(onPressed: () => print(availableServices), child: Text("Fetch services")),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
          ElevatedButton.icon(icon: Icon(Icons.bug_report),onPressed: getConfig, label: Text("getConfig")),
        ),
      ],
    );


  }

}