
import 'package:flutter/material.dart';
import 'package:fothema_companion/main.dart';

class ConfigTile extends StatefulWidget {
  final JsonObj item;
  ConfigTile({required this.item});
  @override
  State<StatefulWidget> createState() => ConfigTileState();
}

class ConfigTileState extends State<ConfigTile>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpansionTile(title: Text("Config"), children: [

      for(var k in widget.item.keys)
        if(widget.item[k] is JsonObj)
          ConfigTile(item: widget.item[k]),

      for(var k in widget.item.keys)
        if(widget.item[k] is List)
          for(var i in widget.item[k])
            TextFormField(initialValue: i, onChanged: (n) => i = n),

      for(var k in  widget.item.keys)
        if(k is !List && k is !JsonObj)
          TextFormField(initialValue: widget.item[k], onChanged: (v) => widget.item[k] = v)



    ]);
  }


}