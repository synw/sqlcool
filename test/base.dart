import 'dart:io';
import 'package:flutter/services.dart';

Directory directory;
const MethodChannel channel = MethodChannel('com.tekartik.sqflite');
final List<MethodCall> log = <MethodCall>[];
bool setupDone = false;

void setup() async {
  if (setupDone) {
    return;
  }
  directory = await Directory.systemTemp.createTemp();

  String response;
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    //print("METHOD CALL: $methodCall");
    log.add(methodCall);
    switch (methodCall.method) {
      case "getDatabasesPath":
        return directory.path;
        break;
      case "insert":
        return 1;
        break;
      case "update":
        return 1;
        break;
      case "query":
        // count query
        if (methodCall.arguments["sql"] ==
            "SELECT COUNT(id) FROM test WHERE id=1") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"count": 1}
          ];
          return res;
        }
        // exists query
        else if (methodCall.arguments["sql"] ==
            "SELECT COUNT(*) FROM test WHERE id=1") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"count": 1}
          ];
          return res;
        } else {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"k": "v"}
          ];
          return res;
        }
    }
    return response;
  });
}
