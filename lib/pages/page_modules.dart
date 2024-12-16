import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/module.dart';
import 'package:fothema_companion/widget/module_container.dart';
import 'package:universal_ble/universal_ble.dart';

import '../configuration.dart';
import '../fothema_config.dart';


class ModulesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GetModulesPageState();

}

class _GetModulesPageState extends State<ModulesPage> {
  late List<MMModule> localActiveModules = activeModules;
  late List<MMModule> localInactiveModules = inactiveModules;
  MMConfig localConfig = config;

  void asyncInitState() async {

    relistModules();
    localActiveModules = activeModules;
    localInactiveModules = inactiveModules;

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


  void upTheChain(MMModule module, int index)  {
    localConfig.modify(index: index, newModule: module);
  }

  void refresh() => setState(() {
    localActiveModules = activeModules;
    localInactiveModules = inactiveModules;
  });

  @override
  Widget build(BuildContext context) {

    List<ModuleContainer> _activeModules = [];
    List<ModuleContainer> _inactiveModules = [];

    for(MMModule module in localActiveModules) {
      ModuleContainer _cont = ModuleContainer( module: module, notify: (m, i) => upTheChain(m, i));
      _activeModules.add(_cont);
    }

    for(MMModule module in localInactiveModules) {
      ModuleContainer _cont = ModuleContainer(module: module, notify: (m, i) => upTheChain(m, i));
      _inactiveModules.add(_cont);
    }

    return (!connected && !debugMode()) ? Container(alignment: Alignment.center, child: Text("Not connected.")) :

    ListView(
        children: [
          SizedBox(height: 30),
          ExpansionTile(initiallyExpanded: false, title: Text("Active"), onExpansionChanged: (b) => refresh, children: [
            Column(children: [ for(ModuleContainer obj in _activeModules) obj ])

          ]),
          ExpansionTile(initiallyExpanded: false, title: Text("Inactive"), onExpansionChanged: (b) => refresh, children: [
             Column(children: [ for(ModuleContainer obj in _inactiveModules) obj ]),
          ]),

          if(debugMode())ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
            ElevatedButton(onPressed: () => print(availableServices), child: Text("Fetch services")),
          ),
          if(debugMode()) ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
            ElevatedButton.icon(icon: Icon(Icons.bug_report),onPressed: () => setState(() {
              getConfig(force: true);
            }), label: Text("Force Update Config")),
          ),

          SizedBox(width: 30),

          ConstrainedBox(constraints: const BoxConstraints(minHeight: 10), child:
            ElevatedButton.icon(icon: Icon(Icons.save),onPressed: () => setState(() {
              config = localConfig;
              updateConfig(config);
            }), label: Text("Save settings")),
          ),
        ],
      );


  }

}