import 'package:flutter/material.dart';

import 'main.dart';

enum ModulePos {

  // see https://docs.magicmirror.builders/modules/configuration.html#example
  TOP_BAR("top_bar", "Top Bar"),
  BOTTOM_BAR("bottom_bar", "Bottom Bar"),

  FULLSCREEN_ABOVE("fullscreen_above", "Fullscreen (Above)"),
  FULLSCREEN_BELOW("fullscreen_below", "Fullscreen (Below)"),

  TOP_LEFT("top_left", "Top Left"),
  TOP_CENTER("top_center", "Top Center"),
  TOP_RIGHT("top_right", "Top Right"),

  UPPER_THIRD("upper_third", "Upper Third"),
  MIDDLE_CENTER("middle_center", "Center"),
  LOWER_THIRD("lower_third", "Lower Third"),

  BOTTOM_LEFT("bottom_left", "Bottom Left"),
  BOTTOM_CENTER("bottom_center", "Bottom Center"),
  BOTTOM_RIGHT("bottom_right", "Bottom Right");

  final String pos;
  final String title;
  const ModulePos(this.pos, this.title);

  static ModulePos from(String from){
    for (var selection in ModulePos.values){
      if(from == selection.pos) return selection;
    }
    throw Exception("No position $from found.");
  }

  static List<DropdownMenuEntry<ModulePos>> entries() {
    List<DropdownMenuEntry<ModulePos>> list = [];
    for (var mod in ModulePos.values){
      list.add(DropdownMenuEntry(value: mod, label: mod.pos));
    }
    return list;
  }

}
class MMModule {

  final JsonObj selectedModule;


  dynamic moduleDataFetch(String valueFromKey){
    for(var key in selectedModule.keys){
      if(key == valueFromKey) return selectedModule[key] ?? "";
    }
  }

  late String title = moduleDataFetch("module") ?? "";
  late String pos = moduleDataFetch("position") ?? "";
  late String displayText = moduleDataFetch("header") ?? "";
  late JsonObj moduleConfig = moduleDataFetch("config") ?? "";
  late String cachedPos = pos.isNotEmpty ? pos : "top-left";

  bool isEnabled(){
    return title != "alert" && pos.isEmpty;
  }
  void disable(){
    cachedPos = pos.isNotEmpty ? pos : "top-left";
    pos = "";
  }

  void enable(){
    pos = cachedPos;
  }

  MMModule(this.selectedModule);

}