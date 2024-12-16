import 'dart:typed_data';
import 'dart:convert';
import 'main.dart';
import 'module.dart';

enum _ListType {

  STRING,
  MODULE,
  NONE

}

class MMConfig {

  dynamic configFetch(String valueFromKey, {listType=_ListType.NONE}){
    if(!exists){
      print("Config does not exist.");
      return;
    }
    for(var key in config.keys){
      if(key == valueFromKey) {

        if(listType != _ListType.NONE) {
          switch (listType) {
            case _ListType.MODULE:
              List<MMModule> list = [];
              int _i = 0;
              for(var x in config[key]) {
                list.add(MMModule(x, index: _i));
                _i++;
              }
              return list;
            case _ListType.STRING:
              return List<String>.from(config[key]);
            }
          }
          return config[key] ?? "";
        }
      }

    switch(listType){
      case _ListType.STRING:
        return List<String>.empty();
      case _ListType.MODULE:
        return List<MMModule>.empty();
    }
  }

  @override
  String toString({includeModules = false}) {
    return
      includeModules
          ? "Config{address=$address,port=$port,basePath=$basePath,ipWhitelist=$ipWhitelist,useHttps=$useHttps,privateKey=$privateKey,certificate=$certificate,language=$language,country=$country,logLevel=$logLevel,timeFormat=$timeFormat,units=$units}"
          : "Config{address=$address,port=$port,basePath=$basePath,ipWhitelist=$ipWhitelist,useHttps=$useHttps,privateKey=$privateKey,certificate=$certificate,language=$language,country=$country,logLevel=$logLevel,timeFormat=$timeFormat,units=$units,modules=$modules";

  }

  MMConfig({required this.config, this.exists = true});

  static MMConfig empty(){
    return MMConfig(config: JsonObj(), exists: false);
  }

  String serialize(){
    return jsonEncode(config);
  }

  Uint8List encode(){
    return utf8.encode(jsonEncode(config));
  }

  void modify({required int index, required dynamic newModule}){
    for(MMModule mod in modules){
      if(index == mod.index){
        modules.remove(modules.elementAt(index));
        modules.insert(index, newModule);
      }
    }
  }
  final JsonObj config;
  
  late String address = configFetch("address");
  late int port = configFetch("port") as int;
  late String basePath = configFetch("basePath");
  late List<String> ipWhitelist = configFetch("ipWhitelist", listType: _ListType.STRING) as List<String>;
  late bool useHttps = configFetch("useHttps") as bool;
  late String privateKey = configFetch("httpsPrivateKey");
  late String certificate = configFetch("httpsCertificate");
  late String language = configFetch("language");
  late String country = configFetch("locale");
  late List<String> logLevel = configFetch("logLevel", listType: _ListType.STRING) as List<String>;
  late int timeFormat = configFetch("timeFormat") as int;
  late String units = configFetch("units");

  late List<MMModule> modules = configFetch("modules", listType: _ListType.MODULE) as List<MMModule>;

  final bool exists;

}

