import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:fothema_companion/main.dart';
import 'package:universal_ble/universal_ble.dart';

import 'config.dart';


const core_service = "4138";
const ping = "413A";
const get = "413B";
const send = "413C";
const backup = "413D";
const connect = "413E";

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
  if(availableServices.isEmpty || modules.isEmpty){
    availableServices = await UniversalBle.discoverServices(deviceId);
  }

}

Future<MMConfig> getConfig() async {
  init();
  var incoming = await UniversalBle.readValue(deviceId, service, get);
  config = jsonDecode(utf8.decode(incoming as List<int>)) as MMConfig;
  print("Retrieved config: $config");
  modules = config.modules;
  return config;
}



void defineService() {
  init();
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

void updateConfig(Map<String, dynamic> config){
  init();
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(jsonEncode(config)), BleOutputProperty.withResponse);
}

void backupConfig(){
  init();
  UniversalBle.writeValue(deviceId, service, backup, utf8.encode("1") /*utf8.encode(jsonEncode(config))*/, BleOutputProperty.withResponse);
}

void pingServer(){
  init();
  print(UniversalBle.readValue(deviceId, service, connect));
}


