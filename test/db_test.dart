import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:sqlcool/sqlcool.dart';

void main() async {
  final directory = await Directory.systemTemp.createTemp();

  const MethodChannel channel = MethodChannel('com.tekartik.sqflite');
  final List<MethodCall> log = <MethodCall>[];
  String response;
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    if (methodCall.method == 'getDatabasesPath') {
      return directory.path;
    }
    return response;
  });

  tearDown(() {
    log.clear();
  });
  group("init", () {
    test("Init db", () async {
      final String schema = """CREATE TABLE item
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
    )""";
      final q = <String>[
        schema,
        'INSERT INTO item(name) values("Name 1")',
        'INSERT INTO item(name) values("Name 2")',
        'INSERT INTO item(name) values("Name 3")',
      ];
      final db = Db();
      await db.init(
          path: "testdb.sqlite", absolutePath: true, queries: q, verbose: true);
      expect(db.isReady, true);
    });

    /*test("Init null db", () async {
      var db = Db();
      Future<void> init() async {
        await db.init(
            path: null, absolutePath: true, queries: [], verbose: true);
      }

      expect(init, throwsException);
    });*/
  });
}
