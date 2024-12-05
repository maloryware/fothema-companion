import 'package:flutter/material.dart';
import 'package:fothema_companion/main.dart';
import 'package:fothema_companion/widget/spaced_row.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // return Placeholder();
    return Column(
      children: [
        SpacedRow(Text("Enable debug mode"), Switch(
          value: debugMode,
          onChanged: (b) => setState(() {
            debugMode = b;
            String s = b ? "enabled" : "disabled";
            print("Debug mode $s.");
          })
        ))
      ],
    );
  }
}