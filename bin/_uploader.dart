part of htnup;

class Uploader {

  static upload(String filePath) {
    var setting = Setting.load();
    if (setting.HatenaID.isEmpty || setting.ApiKey.isEmpty) {
      _fail("Please run \"dart htnup.dart init\"");
      return;
    }
    var file = new File(filePath);
    if (!file.existsSync()) {
      _fail();
      return;
    }
    var title = basenameWithoutExtension(file.path);
    var text = file.readAsStringSync();
    var xml = _getXml(title, text);

    var request = _getRequest(xml, setting);
    var client = new http.Client();
    client.send(request).then((response) {
      response.stream.bytesToString().then((result) {
        if (response.statusCode != 201) {
          _fail("File was not uploaded. ${result}");
          return;
        }
        var xml = parse(result);
        for (var child in xml.findAllElements("link")) {
          for (var attr in child.attributes) {
            if (attr.name.local == "rel" && attr.value == "alternate") {
              var href = child.attributes.where((attr) => attr.name.local == "href").first;
              stdout.writeln(href.value);
              break;
            }
          }
        }
      });
    });
  }

  static http.Request _getRequest(String xml, Setting setting) {
    var url = "https://blog.hatena.ne.jp/${setting.HatenaID}/${setting.BlogID}/atom/entry";
    var basic = CryptoUtils.bytesToBase64(encodeUtf8("${setting.HatenaID}:${setting.ApiKey}"));
    var request = new http.Request("POST", Uri.parse(url))
      ..body = xml
      ..headers[HttpHeaders.AUTHORIZATION] = "Basic ${basic}";
    return request;
  }

  static String _getXml(String title, String text) {
    var builder = new XmlBuilder();
    builder.processing("xml", "version=\"1.0\"");
    builder.element("entry", namespaces :{
      "http://www.w3.org/2005/Atom": ""
    }, nest: () {
      builder.element("title", nest:() {
        builder.text(title);
      });
      builder.element("content", attributes:{
        "type": "text/plain"
      }, nest:() {
        builder.text(text);
      });
    });
    var xmlNode = builder.build();
    return xmlNode.toString();
  }
}
