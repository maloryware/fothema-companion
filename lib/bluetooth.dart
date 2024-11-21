import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_ble/universal_ble.dart';

class Blecomm {

  static const service = "4138";
  static const ping = "413A";
  static const get = "413B";
  static const send = "413C";
  static const backup = "413D";


  static Map<String, dynamic> config = {};
  static List<BleService> availableServices = [];
  static String deviceId = "";


  static Future<Map<String, dynamic>> getConfig() async {

    var incoming = await UniversalBle.readValue(deviceId, service, Blecomm.get);
    config = jsonDecode(utf8.decode(incoming as List<int>));
    print("Retrieved config: $config");
    return config;

  }

  static void updateConfig(Map<String, dynamic> config){
    UniversalBle.writeValue(deviceId, service, Blecomm.send, utf8.encode(jsonEncode(config)), BleOutputProperty.withResponse);

  }

  static void backupConfig(){
    UniversalBle.writeValue(deviceId, service, Blecomm.backup, utf8.encode(jsonEncode(config)), BleOutputProperty.withResponse);
  }



}