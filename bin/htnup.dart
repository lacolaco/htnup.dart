library htnup;

import "dart:io";
import "dart:math";
import "dart:convert";
import "package:args/args.dart";
import "package:path/path.dart";
import "package:xml/xml.dart";
import "package:crypto/crypto.dart";
import "package:utf/utf.dart";
import "package:http/http.dart" as http;

part '_setting.dart';
part '_uploader.dart';

void start(List<String> args) {
  var parser = new ArgParser(allowTrailingOptions: true);
  parser.addCommand("init");
  var result = parser.parse(args);
  if (result.command == null) {
    run(result.rest);
  }
  else {
    switch (result.command.name) {
      case "init" :
        init();
        break;
      default:
        print("${result.command.name} is not exists command");
    }
  }
}

_fail([String message = ""]) {
  stdout.writeln("Failed: ${message}");
}

_succeed() {
  stdout.writeln("Succeeded.");
}

init() {
  var hatenaID = _ask("Hatena ID");
  if (hatenaID == null) {
    _fail();
    return;
  }
  var blogID = _ask("Blog ID");
  if (blogID == null) {
    _fail();
    return;
  }
  var apiKey = _ask("API Key");
  if (apiKey == null) {
    _fail();
    return;
  }
  new Setting(hatenaID.trim(), blogID.trim(), apiKey.trim()).save();
  _succeed();
}

String _ask(String paramName) {
  stdout.writeln("${paramName}:");
  var value = stdin.readLineSync();
  if (value.trim().isEmpty) {
    return null;
  }
  return value;
}

run(List<String> args) {
  if (args.length != 1) {
    _fail("Invalid arguments");
    return;
  }
  if (args[0] == null || args[0].trim().isEmpty) {
    _fail("Invalid file path.");
    return;
  }
  Uploader.upload(args[0]);
}
