import 'dart:convert';
import 'package:fothema_companion/main.dart';
import 'package:universal_ble/universal_ble.dart';

import 'configuration.dart';
import 'fothema_config.dart';
import 'module.dart';


const core_service = "4138";
const ping = "413A";
const get1 = "4881";
const get2 = "4882";
const get3 = "4883";
const get4 = "4884";
const clearbuf = "4991";
const send = "4992";
const saveconf = "4993";
const backup = "413B";
const connect = "413C";

String serverSideConfig = '{"address": "localhost","port": 8080,"basePath": "/","ipWhitelist": ["127.0.0.1", "::ffff:127.0.0.1", "::1"],"useHttps": false,"httpsPrivateKey": "","httpsCertificate": "","language": "en","locale": "en-US","logLevel": ["INFO", "LOG", "WARN", "ERROR"],"timeFormat": 24,"units": "metric","modules": [{"module": "alert"},{"module": "updatenotification","position": "top_bar"},{"module": "clock","position": "top_left"},{"module": "calendar","header": "US Holidays","position": "top_left","config": {"calendars": [{"fetchInterval": 60480000,"symbol": "calendar-check","url": "https://ics.calendarlabs.com/76/mm3137/US_Holidays.ics"}]}},{"module": "compliments","position": "lower_third"},{"module": "weather","position": "top_right","config": {"weatherProvider": "openmeteo","type": "current","lat": 40.776676,"lon": -73.971321}},{"module": "weather","position": "top_right","header": "Weather Forecast","config": {"weatherProvider": "openmeteo","type": "forecast","lat": 40.776676,"lon": -73.971321}},{"module": "newsfeed","position": "bottom_bar","config": {"feeds": [{"title": "New York Times","url": "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"}],"showSourceTitle": true,"showPublishDate": true,"broadcastNewsFeeds": true,"broadcastNewsUpdates": true}}]}';
String debugConfigString = '{"address": "localhost","port": 8080,"basePath": "/","ipWhitelist": ["127.0.0.1", "::ffff:127.0.0.1", "::1"],"useHttps": false,"httpsPrivateKey": "","httpsCertificate": "","language": "en","locale": "en-US","logLevel": ["INFO", "LOG", "WARN", "ERROR"],"timeFormat": 24,"units": "metric","modules": [{"module": "alert"},{"module": "updatenotification","position": "top_bar"},{"module": "clock","position": "top_left"},{"module": "calendar","header": "US Holidays","position": "top_left","config": {"calendars": [{"fetchInterval": 60480000,"symbol": "calendar-check","url": "https://ics.calendarlabs.com/76/mm3137/US_Holidays.ics"}]}},{"module": "compliments","position": "lower_third"},{"module": "weather","position": "top_right","config": {"weatherProvider": "openmeteo","type": "current","lat": 40.776676,"lon": -73.971321}},{"module": "weather","position": "top_right","header": "Weather Forecast","config": {"weatherProvider": "openmeteo","type": "forecast","lat": 40.776676,"lon": -73.971321}},{"module": "newsfeed","position": "bottom_bar","config": {"feeds": [{"title": "New York Times","url": "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"}],"showSourceTitle": true,"showPublishDate": true,"broadcastNewsFeeds": true,"broadcastNewsUpdates": true}}]}';

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
List<BleDevice> devices = [];
List<BleDevice> hiddenDevices = [];
AvailabilityState lastState = AvailabilityState.poweredOn;


Future<void> init() async {
  if((availableServices.isEmpty || modules.isEmpty) && !debugMode){
    availableServices = await UniversalBle.discoverServices(deviceId);
  }

}

Future<MMConfig> getConfig({bool force = false}) async {
  if(debugMode) return debugConfig;

  init();

  if((!force && config.exists) || debugMode){
    return debugMode ? debugConfig : config;
  }

  var incoming = await fetchall();
  config = jsonDecode(utf8.decode(incoming as List<int>)) as MMConfig;
  print("Retrieved config: $config");
  modules = config.modules;
  return config;

}



void defineService() {
  if(debugMode) return;
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
  if(!_success) {
    print("Unable to locate proper service. Is your mirror running the FOTHEMA Server?");
    throw ConnectionException("No correspondent services found.");
  }
}

void updateConfig(MMConfig config){
  init();
  debugMode
      ? serverSideConfig = debugConfig.serialize()
      : UniversalBle.writeValue(deviceId, service, send, config.serialize(encoded: true), BleOutputProperty.withResponse);
}

void backupConfig(){
  init();
  UniversalBle.writeValue(deviceId, service, backup, utf8.encode("1") /*utf8.encode(jsonEncode(config))*/, BleOutputProperty.withResponse);
}

void pingServer(){
  init();
  print(UniversalBle.readValue(deviceId, service, connect));
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

Future<void> sendAll(MMConfig config) async {
  var t = jsonEncode(config);
  print("t: $t\n\n splitting...");
  var _1 = t.substring(0, 400);
  var _2 = t.substring(400, 800);
  var _3 = t.substring(800, 1200);
  var _4 = t.substring(1200, 1600);
  UniversalBle.writeValue(deviceId, service, clearbuf, utf8.encode(""),
      BleOutputProperty.withoutResponse);
  UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_1), BleOutputProperty.withResponse);
  UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_2), BleOutputProperty.withResponse);
  UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_3), BleOutputProperty.withResponse);
  UniversalBle.writeValue(
      deviceId, service, send, utf8.encode(_4), BleOutputProperty.withResponse);
  UniversalBle.writeValue(deviceId, service, saveconf, utf8.encode(""),
      BleOutputProperty.withoutResponse);

}