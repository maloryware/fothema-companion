import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fothema_companion/main.dart';
import 'package:toastification/toastification.dart';
import 'package:universal_ble/universal_ble.dart';

import 'configuration.dart';
import 'fothema_config.dart';
import 'module.dart';


const core_service = "4138";
const get1 = "4881";
const get2 = "4882";
const get3 = "4883";
const get4 = "4884";
const clearbuf = "4991";
const send = "4992";
const saveconf = "4993";
const ping = "413A";
const backup = "413B";
const connect = "413C";
const _getConfigLocation = "413D";
const _getBackupLocation = "413E";
const _restart = "4140";

var _empty = utf8.encode("_");


late String localBackupConfig;
String debugConfigString = '{"address": "localhost","port": 8080,"basePath": "/","ipWhitelist": ["127.0.0.1", "::ffff:127.0.0.1", "::1"],"useHttps": false,"httpsPrivateKey": "","httpsCertificate": "","language": "en","locale": "en-US","logLevel": ["INFO", "LOG", "WARN", "ERROR"],"timeFormat": 24,"units": "metric","modules": [{"module": "alert"},{"module": "updatenotification","position": "top_bar"},{"module": "clock","position": "top_left"},{"module": "calendar","header": "US Holidays","position": "top_left","config": {"calendars": [{"fetchInterval": 60480000,"symbol": "calendar-check","url": "https://ics.calendarlabs.com/76/mm3137/US_Holidays.ics"}]}},{"module": "compliments","position": "lower_third"},{"module": "weather","position": "top_right","config": {"weatherProvider": "openmeteo","type": "current","lat": 40.776676,"lon": -73.971321}},{"module": "weather","position": "top_right","header": "Weather Forecast","config": {"weatherProvider": "openmeteo","type": "forecast","lat": 40.776676,"lon": -73.971321}},{"module": "newsfeed","position": "bottom_bar","config": {"feeds": [{"title": "New York Times","url": "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"}],"showSourceTitle": true,"showPublishDate": true,"broadcastNewsFeeds": true,"broadcastNewsUpdates": true}}]}';
String serverSideConfig = debugConfigString;

MMConfig debugConfig = MMConfig(config: jsonDecode(debugConfigString));
List<MMModule> debugConfigModules = debugConfig.modules;

String service = "";
MMConfig config = MMConfig.empty();
List<MMModule> modules = [];
List<MMModule> activeModules = [];
List<MMModule> inactiveModules = [];
List<BleService> availableServices = [];
String deviceId = "";
bool connected = false;

List<BleDevice> connectedDevices = [];
var noPerms = false;
var isChecking = false;
var isBluetoothOn = false;
String failStateText = "";
List<String> blacklist = [];
List<BleDevice> devices = [];
List<BleDevice> hiddenDevices = [];
AvailabilityState lastState = AvailabilityState.poweredOn;


Future<void> _init() async {
  if((availableServices.isEmpty || modules.isEmpty) && !debugMode()){
    availableServices = await UniversalBle.discoverServices(deviceId);
  }

}

Future<MMConfig> getConfig({bool force = false}) async {
  //if(debugMode) return debugConfig;
  _init();

  if(!force && config.exists){
    return (debugMode() && !forceBluetoothFunctionality()) ? debugConfig : config;
  }

  if((debugMode() && !forceBluetoothFunctionality())) {
    config = debugConfig;
  }

  else {
    if(!connected) return MMConfig.empty();
    await getConfigLocation();
    await getBackupLocation();
    var incoming = await fetchall();
    config = MMConfig(config: jsonDecode(incoming) as JsonObj);
  }

  print("Retrieved config: $config");
  modules = config.modules;
  return config;
}



void defineService() {
  if(debugMode() && !forceBluetoothFunctionality()) return;
  _init();
  bool _success = false;
  for(var serv in availableServices){
    if (BleUuidParser.compareStrings(BleUuidParser.string(serv.uuid), BleUuidParser.string(core_service))){
      service = serv.uuid;
      _success = true;
      break;
    }
  }
  getConfig();
  if(!_success) {
    toastification.show(title: Text("Unable to find service."), autoCloseDuration: Duration(seconds: 3), icon: Icon(Icons.error_outline));
    print("Unable to locate proper service. Is your mirror running the FOTHEMA Server?");
    throw ConnectionException("No correspondent services found.");
  }
}

Future<void> relistModules() async {
  if(!config.exists) config = await getConfig();
  activeModules = [];
  inactiveModules = [];
  for(MMModule mod in config.modules){
    mod.isEnabled() || mod.title == "alert"
        ? activeModules.add(mod)
        : inactiveModules.add(mod);
  }
}

void reload(){
  UniversalBle.readValue(deviceId, service, _restart);
}

void updateConfig(MMConfig config) async{
  _init();
  (debugMode() && !forceBluetoothFunctionality())
      ? serverSideConfig = debugConfig.serialize()
      : await sendAll(config);
  toastification.show(title: Text("Configuration saved."), autoCloseDuration: Duration(seconds: 5));
}

Future<String> getConfigLocation() async{
  _init();
  return (debugMode() && !forceBluetoothFunctionality()) ? "" : utf8.decode(await UniversalBle.readValue(deviceId, service, _getConfigLocation) as List<int>);
}

Future<String> getBackupLocation() async{
  _init();
  return (debugMode() && !forceBluetoothFunctionality()) ? "" : utf8.decode(await UniversalBle.readValue(deviceId, service, _getBackupLocation) as List<int>);
}

void backupConfig(){
  _init();
  UniversalBle.writeValue(deviceId, service, backup, _empty, BleOutputProperty.withResponse);
}

void pingServer() async{
  _init();
  var pong = await UniversalBle.readValue(deviceId, service, ping);
  print(utf8.decode(pong));
  toastification.show(title: Text(utf8.decode(pong)));
}

Future<String> fetchall() async {
  var _1 = utf8.decode(await UniversalBle.readValue(deviceId, service, get1));
  var _2 = utf8.decode(await UniversalBle.readValue(deviceId, service, get2));
  var _3 = utf8.decode(await UniversalBle.readValue(deviceId, service, get3));
  var _4 = utf8.decode(await UniversalBle.readValue(deviceId, service, get4));
  String fetch = "$_1$_2$_3$_4";
  print("Fetch: $fetch");
  return fetch;
}

void signalConnect(){
  print("\n\nconnected!\n\n");
  UniversalBle.readValue(deviceId, service, connect);
}

Future<void> sendAll(MMConfig config) async {
  var t = config.serialize();
  print("t: $t\n\n splitting...");
  var _1 = t.substring(0, 400);
  var _2 = t.substring(400, 800);
  var _3 = t.substring(800, 1200);
  var _4 = t.substring(1200, t.length);
  await UniversalBle.readValue(deviceId, service, clearbuf);
  await UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_1), BleOutputProperty.withoutResponse);
  await UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_2), BleOutputProperty.withoutResponse);
  await UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_3), BleOutputProperty.withoutResponse);
  await UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_4), BleOutputProperty.withoutResponse);
  await UniversalBle.readValue(deviceId, service, saveconf);
  UniversalBle.readValue(deviceId, service, _restart);

}
