
import 'package:flutter/material.dart';
import 'package:fothema_companion/configuration.dart';
import 'package:fothema_companion/widget/option_tile.dart';

class DebugOptions extends MaterialPageRoute<void> {

  DebugOptions() : super(
    builder: (BuildContext context) {
      return Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            children: [
              SizedBox(height: 50),
              OptionTile(
                  title: "Force enable Bluetooth functionality",
                  child: Switch(
                      value: forceBluetoothFunctionality,
                      onChanged: (b) => setState(() {
                        forceBluetoothFunctionality = b;
                      })
                  )
              )

            ]
          )
        )
      );
    }
  );
}