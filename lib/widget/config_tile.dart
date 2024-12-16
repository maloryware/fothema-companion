

import 'package:flutter/material.dart';
import 'package:fothema_companion/main.dart';

class ConfigTile extends StatefulWidget {
  late final dynamic item;
  final List<dynamic> identifier;
  final Function(dynamic, dynamic) update;
  final String title;

  ConfigTile({required this.identifier, required this.item, required this.title, required this.update});

  @override
  State<StatefulWidget> createState() => ConfigTileState();
}

class ConfigTileState extends State<ConfigTile>{



  void localUpdate(ident, nv){
    widget.update(ident, nv);
    print("Updated: ${ident.toString()}, newValue = ${nv.toString()}");
  }

  @override
  Widget build(BuildContext context) {


    List<Widget> children = [];

  // if the object is a map

    if(widget.item is JsonObj)

      for(var k in widget.item.keys)

        // if "k" of object is a map

        if(widget.item[k] is JsonObj){

          var _ident = List<dynamic>.from(widget.identifier);
          // create a new identifier that takes the first and adds its key to the list
          _ident.add(k.toString());
          
          children.add(
              ConfigTile(
                update: (i, n) => localUpdate,
                item: widget.item[k],
                title: k.toString(),
                identifier: _ident,
              )
          );
          debugPrint("Config tile -> $_ident, \nitem: ${widget.item[k]}, \nparent: ${widget.item}");
        }

        // if "k" of object is a list

        else if(widget.item[k] is List<dynamic>) {
          int _x = 0;
          for (var i in widget.item[k]) {
            var _ident = List<dynamic>.from(widget.identifier);
            _ident.add(_x.toString());
            _x++;
            // if "i" of object[k] is a map or a list
            if (i is JsonObj || i is List<dynamic>) {

              children.add(
                // create another configtile for it
                  ConfigTile(
                    identifier: _ident,
                    item: i,
                    title:
                    i is JsonObj &&
                        !(widget.item[k] is JsonObj ||
                            widget.item[k] is List<dynamic>)
                        ? widget.item[k].toString()
                        : _x.toString(),
                    update: (i, n) => localUpdate,
                  )
              );
              debugPrint("Config tile -> $_ident, \nitem: $i, \nparent: ${widget.item[k]}");
            }
            // if "i" of object[k] is neither
            else
              children.add(
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Expanded(
                          child: TextFormField(
                              initialValue: i, onChanged: (v)
                          {
                            var _ident = List<dynamic>.from(widget.identifier);
                            _ident.add(i);
                            localUpdate(_ident, v);
                          })),
                    ],
                  )
              );
          }
        }


          // if "k" object is neither
        else children.add(
              Row(
                children: [
                  SizedBox(width: 5),
                  Text(k.toString()),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(initialValue: "${widget.item[k]}", onChanged: (v) {
                      var _ident = List<dynamic>.from(widget.identifier);
                      _ident.add(k);
                      localUpdate(_ident, v);
                    }),
                  ),
                ],
              )
          );

    // if the object is neither

    if(widget.item is !List<dynamic> && widget.item is !JsonObj)
      children.add(
          Row(
            children: [
              SizedBox(width: 5),
              Text(widget.item),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(initialValue: "${widget.item}", onChanged: (v) {
                  var _ident = List<dynamic>.from(widget.identifier);
                  _ident.add(widget.item);
                  localUpdate(_ident, v);
                }),
              ),
            ],
          )
      );

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: ExpansionTile(
          onExpansionChanged: (b) => setState(() {}),
          title: Text(widget.title),
          children: [
            for(Widget n in children) n

      ]),
    );
  }


}