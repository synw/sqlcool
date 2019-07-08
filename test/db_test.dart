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
    //print("METHOD CALL: $methodCall");
    log.add(methodCall);
    if (methodCall.method == 'getDatabasesPath') {
      return directory.path;
    } else if (methodCall.method == "insert") {
      return 1;
    } else if (methodCall.method == "update") {
      return 1;
    } else if (methodCall.method == "query") {
      final res = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return res;
    }
    return response;
  });

  tearDown(() {
    log.clear();
  });

  final db = Db();

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

      await db.init(
          path: "testdb.sqlite", absolutePath: true, queries: q, verbose: true);
      expect(db.isReady, true);
      return true;
    });

    test("Insert", () async {
      Future<int> insert() async {
        final res =
            await db.insert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

      final dynamic res = await insert();
      print("RES $res / ${res.runtimeType}");
      return insert().then((int r) => expect(r, 1));
    });

    test("Delete", () async {
      Future<int> delete() async {
        final res =
            await db.delete(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return delete().then((int r) => expect(r, 1));
    });

    test("Update", () async {
      Future<int> update() async {
        final res = await db.update(
            table: "test", where: "id=1", row: {"k": "v"}, verbose: true);
        return res;
      }

      return update().then((int r) => expect(r, 1));
    });

    test("Upsert", () async {
      Future<Null> upsert() async {
        final Null res =
            await db.upsert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

      return upsert().then((r) => expect(r, null));
    });

    test("Select", () async {
      Future<List<Map<String, dynamic>>> select() async {
        final res =
            await db.select(table: "test", where: "id=1", verbose: true);
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return select().then((List<Map<String, dynamic>> r) => expect(r, output));
    });

    test("Join", () async {
      Future<List<Map<String, dynamic>>> join() async {
        final res = await db.join(
            table: "test",
            joinOn: "table1.id=1",
            joinTable: "table1",
            where: "id=1",
            verbose: true);
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return join().then((List<Map<String, dynamic>> r) => expect(r, output));
    });

    test("Query", () async {
      Future<List<Map<String, dynamic>>> query() async {
        final res = await db.query("SELECT * from test_table");
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return query().then((List<Map<String, dynamic>> r) => expect(r, output));
    });
  });
}
