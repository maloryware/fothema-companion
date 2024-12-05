import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/module.dart';
import 'package:fothema_companion/widget/module_container.dart';
import 'package:fothema_companion/widget/modules_box.dart';
import 'package:universal_ble/universal_ble.dart';

import '../config.dart';

class ModulesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModulesPageState();

}

class _ModulesPageState extends State<ModulesPage> {

  void asyncInitState() async {

    if(modules.isEmpty) {
      getConfig();
    }

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

    // return !connected ? Container(alignment: Alignment.center, child: Text("Not connected.")):

    return Column(

      children: [
        ExpansionTile(initiallyExpanded: false, title: Text("Active"), children: [
          for(MMModule mod in activeModules) ModuleContainer(mod)
        ]),
        ExpansionTile(initiallyExpanded: false, title: Text("Inactive"), children: [
          for(MMModule mod in inactiveModules) ModuleContainer(mod)
        ]),

        ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
          ElevatedButton(onPressed: () => print(availableServices), child: Text("Fetch services")),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
          ElevatedButton.icon(icon: Icon(Icons.bug_report),onPressed: () => getConfig(force: true), label: Text("Force Update Config")),
        ),
      ],
    );


  }

}