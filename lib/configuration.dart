import 'dart:convert';
import 'dart:io';
import 'package:fothema_companion/defaults.dart';
import 'package:path_provider/path_provider.dart';

late Map<String, dynamic> _settings;

late bool _debugMode;
late bool _forceBluetoothFunctionality;
late String _configLocation;
late String _backupLocation;

bool debugMode() => _debugMode;
bool forceBluetoothFunctionality() => _forceBluetoothFunctionality;
String configLocation() => _configLocation;
String backupLocation() => _backupLocation;

enum Settings{
  DEBUG,
  DEBUG_FORCE_BLUETOOTH_FUNCTIONALITY,
  SET_CONFIG_LOCATION,
  SET_BACKUP_LOCATION
}

void updateSetting({required Settings setting, required var value}){

  switch(setting){
    case Settings.DEBUG:
      _debugMode = value;
    case Settings.DEBUG_FORCE_BLUETOOTH_FUNCTIONALITY:
      _forceBluetoothFunctionality = value;
    case Settings.SET_BACKUP_LOCATION:
      _backupLocation = value;
    case Settings.SET_CONFIG_LOCATION:
      _configLocation = value;
  }
  _save();

}

dynamic _loadObject({required obj}) async {
  _settings = await _load();
  return await _settings[obj];
}


Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}


Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/settings.json');
}

Future<File> _save() async {

  Map<String, dynamic> settings = {
    "debugMode": _debugMode,
    "forceBluetoothFunctionality": _forceBluetoothFunctionality
  };

  final file = await _localFile;
  return file.writeAsString(jsonEncode(settings));
}

Future<Map<String, dynamic>> _load() async {
  late Map<String, dynamic> output;

  try {
    final file = await _localFile;

    final contents = await file.readAsString();
    output = jsonDecode(contents);

  }

  catch (e) {
    output = _loadDefaults();
    createLocalSettingsFile();
  }

  return output;
}

Map<String, dynamic> _loadDefaults(){
  return defaults;
}

Future<void> startupSettingsInit() async {
  _load();
  _forceBluetoothFunctionality = await _loadObject(obj: "forceBluetoothFunctionality");
  _debugMode = await _loadObject(obj: "debugMode");
  // the info below is located on the server side and therefore is not stored locally
  _configLocation = "";
  _backupLocation = "";
}

Future<File> createLocalSettingsFile() async {
  final file = await _localFile;
  return file.writeAsString(jsonEncode(defaults));
}


