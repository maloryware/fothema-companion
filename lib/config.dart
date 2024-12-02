
import 'main.dart';
import 'module.dart';


class MMConfig {

  dynamic configFetch(String valueFromKey){
    for(var key in config.keys){
      if(key == valueFromKey) return config[key] ?? "";
    }
  }

  final JsonObj config;
  
  late String address = configFetch("address");
  late int port = configFetch("port") as int;
  late String basePath = configFetch("basePath");
  late List<String> ipWhitelist = configFetch("ipWhitelist") as List<String>;
  late bool useHttps = configFetch("useHttps") as bool;
  late String privateKey = configFetch("");
  late String certificate = configFetch("httpsCertificate");
  late String language = configFetch("language");
  late String country = configFetch("locale");
  late List<String> logLevel = configFetch("logLevel") as List<String>;
  late int timeFormat = configFetch("timeFormat") as int;
  late String units = configFetch("units");

  late List<MMModule> modules = configFetch("modules") as List<MMModule>;

  final bool exists;

  @override
  String toString() {
    // TODO: implement toString
    return "Config{address=$address,port=$port,basePath=$basePath,ipWhitelist=$ipWhitelist,useHttps=$useHttps,privateKey=$privateKey,certificate=$certificate,language=$language,country=$country,logLevel=$logLevel,timeFormat=$timeFormat,units=$units";
  }

  MMConfig({required this.config, this.exists = true});
  MMConfig empty(){
    return MMConfig(config: JsonObj(), exists: false);
  }

}

