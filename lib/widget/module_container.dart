import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/widget/config_tile.dart';

import '../module.dart';

class ModuleContainer extends StatefulWidget {
  final MMModule module;
  final Function(dynamic, dynamic) notify;

  ModuleContainer({required this.module, required this.notify});

  @override
  State<StatefulWidget> createState() => _ModuleContainerState();
}

enum ModuleType { ACTIVE, INACTIVE }

class _ModuleContainerState extends State<ModuleContainer> {
  //displaytext, position, config

  late MMModule module;
  late ModuleType type;
  late ModulePos pos;
  final TextEditingController displayTextHandler = TextEditingController();

  void updateDisplayText(String newDisplayText) {
    module.displayText = newDisplayText;
    widget.notify(module, module.index);
  }

  void updatePos(ModulePos newPos) {
    module.pos = newPos;
    widget.notify(module, module.index);
  }

  void onUpdate(List ident, nv){

    module.moduleConfig[ident.last] = nv;
    widget.notify(module, module.index);

  }

  @override
  void initState() {
    type = widget.module.isEnabled() ? ModuleType.ACTIVE : ModuleType.INACTIVE;
    pos = widget.module.isEnabled() ? widget.module.pos : widget.module.cachedPos;
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
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: ExpansionTile(
          leading: module.title != "alert"
              ? Switch(
                  value: module.isEnabled(),
                  onChanged: (b) => setState(() {
                        b ? module.enable() : module.disable();
                        relistModules();
                        widget.notify;
                      }))
              : null,

          title: Text(module.title),
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text("Display text: "),
              Expanded(
                child: TextFormField(
                  initialValue: displayTextHandler.text,
                  onChanged: (String value) => updateDisplayText,
                ),
              ),
              SizedBox(width: 10)
            ]),
            // Position
           if(widget.module.title != "alert") SizedBox(
              height: 100,
              child:  Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Position: "),
                DropdownMenu<ModulePos>(
                  initialSelection: module.pos,
                  dropdownMenuEntries: ModulePos.entries(),
                  onSelected: (newPos) => updatePos,
                )
              ]),
            ),
            // Module configuration
            if(
                widget.module.title != "alert" &&
                widget.module.title != "updatenotification" &&
                widget.module.title != "clock" &&
                widget.module.title != "compliments")
                  ConfigTile(
                    identifier: [module.index, "config"],
                    item: module.moduleConfig,
                    title: "Config",
                    update: (i, v) => onUpdate(i, v))
          ]),
    );
  }
}
