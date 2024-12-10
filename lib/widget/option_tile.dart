import 'package:flutter/material.dart';

enum OptionType {
  SWITCH,
  PAGE
}

class OptionTile extends StatelessWidget {
  final String title;
  final Widget? child;
  final GestureTapCallback? onTap;
  final bool? enabled;

  OptionTile({this.enabled, this.child, this.onTap, required this.title});

  @override
  Widget build( context) {
    // TODO: implement build

    if(child == null && onTap == null) throw ArgumentError("Arguments 'child' and 'onTap' must not be simultaneously empty. Add 'child' or 'onTap' to your widget.");
    if(child != null && onTap != null) throw ArgumentError("Arguments 'child' and 'onTap' cannot both be declared. Remove one.");
    return child == null && onTap != null
        ? InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
          child: Row(children: [
            SizedBox(width: 10),
            Text(title),
            Expanded(child: SizedBox()),
            SizedBox(width: 10)
          ]),
        ))
        : Row(children: [
            SizedBox(width: 10),
            Text(title),
            Expanded(child: SizedBox()),
            child as Widget,
            SizedBox(width: 10)
        ]);
  }

}