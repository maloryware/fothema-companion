import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:universal_ble/universal_ble.dart';


const core_service = "4138";
const ping = "413A";
const get = "413B";
const send = "413C";
const backup = "413D";
const connect = "413E";

String service = "";
Map<String, dynamic> config = {};
Map<String, dynamic> modules = {};
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

Future<Map<String, dynamic>> getConfig() async {
  var incoming = await UniversalBle.readValue(deviceId, service, get);
  config = jsonDecode(utf8.decode(incoming as List<int>));
  print("Retrieved config: $config");
  for (var key in config.keys){
    if(key == "modules"){
      modules = jsonDecode(key);
    }
  }
  return config;
}

void defineService() {
  for(var serv in availableServices){
    if (BleUuidParser.compareStrings(BleUuidParser.string(serv.uuid), core_service)){
      service = serv.uuid;
      break;
    }
  }
}

void updateConfig(Map<String, dynamic> config){
  UniversalBle.writeValue(deviceId, service, send, utf8.encode(jsonEncode(config)), BleOutputProperty.withResponse);
}

void backupConfig(){
  UniversalBle.writeValue(deviceId, service, backup, utf8.encode("1") /*utf8.encode(jsonEncode(config))*/, BleOutputProperty.withResponse);
}

void pingServer(){
  print(UniversalBle.readValue(deviceId, service, connect));
}


