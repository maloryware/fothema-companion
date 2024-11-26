import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:fothema_companion/bluetooth.dart';
import 'package:fothema_companion/main.dart';
import 'package:universal_ble/universal_ble.dart';

import 'config.dart';


const core_service = "4138";
const ping = "413A";
const backup = "413B";
const connect = "413C";

const get1 = "4881";
const get2 = "4882";
const get3 = "4883";
const get4 = "4884";

const clearbuf = "4991";
const send = "4992";
const saveconf = "4993";

String service = "";
late MMConfig config;
List<MMModule> modules = [];
List<BleService> availableServices = [];
String deviceId = "";
bool connected = false;

List<BleDevice> connectedDevices = [];
var noPerms = false;
var isChecking = false;
var isBluetoothOn = false;
String failStateText = "";
List<BleDevice> devices = [];
List<BleDevice> hiddenDevices = [];
AvailabilityState lastState = AvailabilityState.poweredOn;

var activeModules = [];
var inactiveModules = [];

Future<void> init() async {
  if(availableServices.isEmpty){
    print("------------------ Running method init() ------------------");
    availableServices = await UniversalBle.discoverServices(deviceId);
    UniversalBle.writeValue(deviceId, service, connect, Uint8List(1), BleOutputProperty.withResponse);
  }
}

Future<MMConfig> getConfig() async {
  init();
  print("------------------ Running method getConfig() ------------------");
  var incoming = await fetchall();
  print("Incoming: $incoming");
  config = MMConfig(jsonDecode(incoming));
  print("Retrieved config: $config");
  modules = config.modules;
  return config;
}


void defineService() {
  init();
  print("------------------ Running method defineService() ------------------");
  bool _success = false;
  for(var serv in availableServices){
    if (BleUuidParser.compareStrings(BleUuidParser.string(serv.uuid), BleUuidParser.string(core_service))){
      service = serv.uuid;
      _success = true;
      break;
    }
  }
  getConfig();
  if(!_success) print("Unable to locate proper service. Is your mirror running the FOTHEMA Server?");
}

Future<void> updateConfig(MMConfig config) async {
  init();
  await sendAll(config);
}

void backupConfig(){
  init();
  UniversalBle.writeValue(deviceId, service, backup, utf8.encode("") /*utf8.encode(jsonEncode(config))*/, BleOutputProperty.withResponse);
}

void pingServer(){
  init();
  print(UniversalBle.readValue(deviceId, service, ping));
}







// these are disgusting and we should all pretend they don't exist. DON'T DO THIS! I'M STUPID AND LAZY!

Future<String> fetchall() async {
  var _1 = utf8.decode(await UniversalBle.readValue(deviceId, service, get1));
  var _2 = utf8.decode(await UniversalBle.readValue(deviceId, service, get2));
  var _3 = utf8.decode(await UniversalBle.readValue(deviceId, service, get3));
  var _4 = utf8.decode(await UniversalBle.readValue(deviceId, service, get4));
  String fetch = "$_1$_2$_3$_4";
  print("Fetch: $fetch");
  return fetch;
}

Future<void> sendAll(MMConfig config) async {
  var t = jsonEncode(config);
  print("t: $t\n\n splitting...");
  var _1 = t.substring(0, 400);
  var _2 = t.substring(400, 800);
  var _3 = t.substring(800, 1200);
  var _4 = t.substring(1200, 1600);
  UniversalBle.writeValue(deviceId, service, clearbuf, utf8.encode(""), BleOutputProperty.withoutResponse);
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(_1), BleOutputProperty.withResponse);
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(_2), BleOutputProperty.withResponse);
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(_3), BleOutputProperty.withResponse);
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(_4), BleOutputProperty.withResponse);
  UniversalBle.writeValue(deviceId, service, saveconf, utf8.encode(""), BleOutputProperty.withoutResponse);

}