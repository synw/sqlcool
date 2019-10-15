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
    print("METHOD CALL: $methodCall");
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
      case "batch":
        return [1, 2];
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
        } // bloc select query
        else if (methodCall.arguments["sql"] == "SELECT * FROM test") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"k": "v"},
            <String, dynamic>{"k": "v"},
          ];
          return res;
        } // dbmodels select
        else if (methodCall.arguments["sql"] ==
            "SELECT id,name,price FROM car WHERE price=30000") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"name": "My car", "price": 30000.0},
          ];
          return res;
        } // dbmodels other select
        else if (methodCall.arguments["sql"] ==
            'SELECT id,name,price FROM car WHERE name="My car"') {
          final res = <Map<String, dynamic>>[];
          return res;
        }
        // dbmodels other select
        else if (methodCall.arguments["sql"] ==
            "SELECT id,name,price FROM car WHERE price=40000") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{"name": "My car", "price": 40000.0},
          ];
          return res;
        } // dbmodels foreign key
        else if (methodCall.arguments["sql"] ==
            "SELECT car.id AS id,car.name AS name,car.price AS price,manufacturer.name " +
                "AS manufacturer_name,manufacturer.id AS manufacturer_id FROM car " +
                "INNER JOIN manufacturer ON car.manufacturer=manufacturer.id") {
          final res = <Map<String, dynamic>>[
            <String, dynamic>{
              "id": 1,
              "name": "My car",
              "price": 10000.0,
              "manufacturer_name": "My manufacturer",
              "manufacturer_id": 1
            },
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
