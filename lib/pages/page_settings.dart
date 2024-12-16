import 'package:flutter/material.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/settings_routes/route_debug.dart';
import 'package:fothema_companion/widget/option_tile.dart';
import 'package:toastification/toastification.dart';

import '../configuration.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  TextEditingController backupController = TextEditingController();
  TextEditingController configController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    backupController.text = backupLocation();
    configController.text = configLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // return Placeholder();
    return Column(
      children: [
        SizedBox(height: 30),

        OptionTile(title: "Set config location",
            onTap: () => (connected)
                ? showDialog(
                  context: context, builder: (context) =>
                    _PopupDialog(
                        context: context,
                        controller: configController,
                        setting: Settings.SET_CONFIG_LOCATION,
                        boxTitle: "Config location"))
                : toastification.show(
                  title: Text("Not connected."),
                  autoCloseDuration: const Duration(seconds: 3),
                  icon: Icon(Icons.wifi_off))),



        OptionTile(title: "Set backup location",
            onTap: () => (connected)
                ? showDialog(context: context, builder: (context) =>
                  _PopupDialog(
                      context: context,

                      controller: backupController,
                      setting: Settings.SET_BACKUP_LOCATION,
                      boxTitle: "Backup location"))
                : toastification.show(
                  title: Text("Not connected."),
                  autoCloseDuration: const Duration(seconds: 3),
                  icon: Icon(Icons.wifi_off))),

        OptionTile(
            title: "Restore from backup",
            onTap: () {}),
        OptionTile(
            title: "Save to backup",
            onTap: () {} ),


        // -------------- debug -------------- //


        OptionTile(
            title: "Enable debug mode",
            child: Switch(
              value: debugMode(),
              onChanged: (b) => setState(() {
                updateSetting(setting: Settings.DEBUG, value: b);
                String s = b ? "enabled" : "disabled";
                print("Debug mode $s.");
                getConfig();
                relistModules();
              }),
            )),


        if(debugMode()) OptionTile(
          title: "Debug options",
          onTap: () => Navigator.push(context, DebugOptions()),
        ),

        Center(child: ElevatedButton(onPressed: pingServer, child: Icon(Icons.network_ping)),)
      ],
    );
  }
}

class _PopupDialog extends StatelessWidget {
  final TextEditingController controller;
  final String boxTitle;
  final BuildContext context;
  final Settings setting;
  _PopupDialog({required this.context, required this.controller, required this.setting, this.boxTitle = ""});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    toastification.show(title: Text("Current location: ${controller.text}"));
    return AlertDialog(
        title: Text(boxTitle),
        content:TextField(controller: controller, decoration: InputDecoration(hintText: controller.text), ),
        actions: <Widget>[
          FloatingActionButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          FloatingActionButton(onPressed: () => updateSetting(setting: setting, value: controller.text), child: Text("Save"))
        ]);
  }
}