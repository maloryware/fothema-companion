
import 'main.dart';

class MMConfig {

  dynamic configFetch(String valueFromKey){
    for(var key in config.keys){
      if(key == valueFromKey) return config[key] ?? "";
    }
  }

  List<String> configFetchList(String valueFromKey){
    for(var key in config.keys){
      if(key == valueFromKey) return config[key] ?? "";
    }
    return [];
  }

  List<MMModule> fetchModules(){
    for(var key in config.keys){
      if(key == "modules") {
        List<MMModule> list = [];
        for(var mod in config[key]){
          list.add(MMModule(mod));
        }
        return list;
      }
    }
    return [];
  }


  final JsonObj config;
  
  late String address = configFetch("address");
  late int port = configFetch("port") as int;
  late String basePath = configFetch("basePath");
  late List<String> ipWhitelist = configFetchList("ipWhitelist");
  late bool useHttps = configFetch("useHttps") as bool;
  late String privateKey = configFetch("httpsPrivateKey");
  late String certificate = configFetch("httpsCertificate");
  late String language = configFetch("language");
  late String country = configFetch("locale");
  late List<String> logLevel = configFetchList("logLevel");
  late int timeFormat = configFetch("timeFormat") as int;
  late String units = configFetch("units");

  late List<MMModule> modules = fetchModules();

  @override
  String toString() {
    // TODO: implement toString
    var _0, _1 = "UNIMPLEMENTED";
    return "Config{address=$address,port=$port,basePath=$basePath,ipWhitelist=$_0,useHttps=$useHttps,privateKey=$privateKey,certificate=$certificate,language=$language,country=$country,logLevel=$_1,timeFormat=$timeFormat,units=$units";
  }

  MMConfig(this.config);

}

class MMModule {

  final JsonObj selectedModule;


  dynamic moduleDataFetch(String valueFromKey){
    for(var key in selectedModule.keys){
      if(key == valueFromKey) return selectedModule[key] ?? "";
    }
  }

  late String title = moduleDataFetch("module") ?? "";
  late String pos = moduleDataFetch("position") ?? "";
  late String displayText = moduleDataFetch("header") ?? "";
  late JsonObj moduleConfig = moduleDataFetch("config") ?? "";
  late String cachedPos = pos.isNotEmpty ? pos : "top-left";

  void disable(){
    cachedPos = pos.isNotEmpty ? pos : "top-left";
    pos = "";
  }

  void enable(){
    pos = cachedPos;
  }

  MMModule(this.selectedModule);

}