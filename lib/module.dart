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
  BOTTOM_RIGHT("bottom_right", "Bottom Right"),
  NONE("null", "null");

  final String pos;
  final String title;
  const ModulePos(this.pos, this.title);

  bool isEmpty(){
    return this == ModulePos.NONE;
  }
  static ModulePos from(String from){
    for (var selection in ModulePos.values){
      if(from == selection.pos) return selection;
    }
    throw Exception("No position $from found.");
  }

  @override
  String toString(){
    return pos;
  }

  static List<DropdownMenuEntry<ModulePos>> entries() {
    List<DropdownMenuEntry<ModulePos>> list = [];
    for (var mod in ModulePos.values){
      list.add(DropdownMenuEntry(value: mod, label: mod.title));
    }
    return list;
  }

}
class MMModule {

  @override
  String toString() {
    // TODO: implement toString
    return "MMModule$selectedModule";
  }
  final JsonObj selectedModule;


  dynamic moduleDataFetch(String valueFromKey){
    for(var key in selectedModule.keys){
      if(key == valueFromKey)
        return valueFromKey == "position" ? ModulePos.from(selectedModule[key]) : selectedModule[key];
    }
  }

  late String title = moduleDataFetch("module") ?? "";
  late ModulePos pos = moduleDataFetch("position") ?? ModulePos.NONE;
  late String displayText = moduleDataFetch("header") ?? "";
  late JsonObj moduleConfig = moduleDataFetch("config") ?? <String, dynamic>{};
  late ModulePos cachedPos = pos != ModulePos.NONE ? pos : ModulePos.TOP_LEFT;

  bool isEnabled(){
    return title != "alert" && pos == ModulePos.NONE;
  }
  void disable(){
    cachedPos = pos != ModulePos.NONE ? pos : ModulePos.TOP_LEFT;
    pos = ModulePos.NONE;
  }

  void enable(){
    pos = cachedPos;
  }

  static JsonObj serialize({required MMModule module}){
    return <String, dynamic>{
      "title": module.title,
      "pos": module.pos.toString(),
      "header": module.displayText,
      "config": module.moduleConfig
    };
  }
  MMModule(this.selectedModule);

}