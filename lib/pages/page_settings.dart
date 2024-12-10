import 'package:flutter/material.dart';
import 'package:fothema_companion/main.dart';
import 'package:fothema_companion/settings_routes/route_debug.dart';
import 'package:fothema_companion/widget/option_tile.dart';

import '../configuration.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {



  @override
  Widget build(BuildContext context) {
    // return Placeholder();
    return Column(
      children: [
        SizedBox(height: 50),
        OptionTile(
            title: "Enable debug mode",
            child: Switch(
              value: debugMode,
              onChanged: (b) => setState(() {
                debugMode = b;
                String s = b ? "enabled" : "disabled";
                print("Debug mode $s.");
              }),
            )),
        if(debugMode) OptionTile(
          title: "Debug options",
          onTap: () => Navigator.push(context, DebugOptions()),
        )
      ],
    );
  }
}