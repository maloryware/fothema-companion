
import 'package:flutter/material.dart';
import 'package:fothema_companion/widget/config_tile.dart';
import '../widget/modules_box.dart';

import '../module.dart';

class ModuleContainer extends StatefulWidget {
  final MMModule module;
  ModuleContainer(this.module);

  @override
  State<StatefulWidget> createState() => _ModuleContainerState();
}

class _ModuleContainerState extends State<ModuleContainer> {

  //displaytext, position, config

  late MMModule module;
  late ModuleType type;
  final TextEditingController displayTextHandler = TextEditingController();

  void updateDisplayText(String newDisplayText){
    module.displayText = newDisplayText;
  }

  void updatePos(ModulePos newPos){
    module.pos = newPos;
  }

  void updateModuleConfig(String key, String newValue){
    module.moduleConfig[key] = newValue;
  }

  @override
  void initState(){
    type = widget.module.isEnabled() ? ModuleType.ACTIVE : ModuleType.INACTIVE;
    module = widget.module;

    displayTextHandler.text = module.displayText;
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    //throw UnimplementedError();
  }


  @override
  Widget build(BuildContext context) {
    return
      Expanded(
        child: ExpansionTile(title: Text(module.title), children: [
          // Display text
          Container(
            padding: EdgeInsets.only(left: 1.0),
            child: Row(children: [
              Text("Display text: "),
              TextFormField(
                initialValue: displayTextHandler.text,
                onChanged: (String value) => updateDisplayText,
              )
            ]),
          ),
          // Position
          Container(
            padding: EdgeInsets.only(left: 1.0),
            child: Row(children: [
              Text("Position: "),
              DropdownMenu<ModulePos>(
                initialSelection: module.pos,
                dropdownMenuEntries: ModulePos.entries(),
                onSelected: (newPos) => updatePos,
              )
            ]),
          ),
          // Module configuration
          Container(
            padding: EdgeInsets.only(left: 1.0),
            child: ExpansionTile(
              title: Text("Configuration"),
              children: [
                ConfigTile(item: module.moduleConfig)
              ],

            ),
          )
        ],
            ),
      );

  }

}