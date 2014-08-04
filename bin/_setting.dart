part of htnup;

class Setting {


  String HatenaID;
  String BlogID;
  String ApiKey;

  Setting(this.HatenaID, this.BlogID, this.ApiKey);

  static Setting load({String fileName: "setting.json"}) {
    var file = _getFile(fileName:fileName);
    if (!file.existsSync()) {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(JSON.encode(new Setting("", "", "")));
    }
    Map<String, String> settingJson = JSON.decode(file.readAsStringSync());
    return new Setting(settingJson["hatena_id"], settingJson["blog_id"], settingJson["api_key"]);
  }

  static File _getFile({String fileName: "setting.json"}) {
    var path = Platform.environment["HOME"] + "/.htnup/${fileName}";
    var file = new File(path);
    return file;
  }

  void save({String fileName: "setting.json"}) {
    var file = _getFile(fileName:fileName);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(JSON.encode(this));
  }

  dynamic toJson() {
    return {
      "hatena_id" : HatenaID,
      "blog_id" : BlogID,
      "api_key" : ApiKey
    };
  }
}
