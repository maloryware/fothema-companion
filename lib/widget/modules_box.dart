
import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';

import '../fothema_config.dart';
import '../module.dart';

/*

  module maps are comprised of the following keys
    [0] ALWAYS - module -> the title of the module
    [1] position -> the relative position of the module (see exceptions)
            this can be changed to exact values via CSS; low priority tho
        header -> a title (if applicable)
        config -> configuration (if applicable)

    exceptions to position: alert
 */

enum ModuleType{
  ACTIVE,
  INACTIVE
}

class ModulesBox extends ExpansionTile{

  ModulesBox({
    required this.moduleType,
    super.key,
    super.leading,
    super.subtitle,
    super.onExpansionChanged,
    super.trailing,
    super.showTrailingIcon = true,
    super.initiallyExpanded = false,
    super.maintainState = false,
    super.tilePadding,
    super.expandedCrossAxisAlignment,
    super.expandedAlignment,
    super.childrenPadding,
    super.backgroundColor,
    super.collapsedBackgroundColor,
    super.textColor,
    super.collapsedTextColor,
    super.iconColor,
    super.collapsedIconColor,
    super.shape,
    super.collapsedShape,
    super.clipBehavior,
    super.controlAffinity,
    super.controller,
    super.dense,
    super.visualDensity,
    super.minTileHeight,
    super.enableFeedback = true,
    super.enabled = true,
    super.expansionAnimationStyle
  }) : super(title: Text("Active"));
  final ModuleType moduleType;

  @override
  State<ExpansionTile> createState() => _ModuleBoxState();


}

class _ModuleBoxState extends State<ModulesBox>{

  late List<MMModule> activeModules;
  late List<MMModule> inactiveModules;

  void toggleModule(MMModule module, bool newVal){

    // caring about the value that the button passes is for BOYS
    // i'm a MAN and i RELY ENTIRELY on my ABILITY to WRITE CONSISTENT CODE
    //
    // TODO: double check this method in case the button and actual value desync

    if(activeModules.contains(module)){
      activeModules.remove(module);
      inactiveModules.add(module);
      module.disable();
    }

    else{
      inactiveModules.remove(module);
      activeModules.add(module);
      module.enable();
    }
  }


  @override
  void initState() {

    super.initState();
    //for(var mod in modules) {
    for(var mod in modules){
      if(mod.title == "alert") continue;
      mod.pos.isEmpty() ? activeModules.add(mod) : inactiveModules.add(mod);
    }
  }

  @override
  Widget build(BuildContext context) {
    var modules = widget.moduleType == ModuleType.ACTIVE ? activeModules : inactiveModules;

    return ExpansionTile(
      title: Text(widget.moduleType == ModuleType.ACTIVE ? "Active" : "Inactive"),
      children: [
        for(MMModule module in modules)
          Row(
            children: [
              Flex(direction: Axis.vertical, children: [Switch(value: activeModules.contains(module), onChanged: (changed) => toggleModule(module, changed))],),
              ExpansionTile(
                title: Text(module.displayText.isNotEmpty ? module.displayText : module.title),
                childrenPadding: EdgeInsets.only(left: 3.0),
                children: [
                  Row(
                    children: [
                      TextFormField(

                      )
                    ],
                  )
                ],
              )
            ],
          )

        ]
      );


  }

}



