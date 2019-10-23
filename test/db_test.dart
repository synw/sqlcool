import 'package:flutter_test/flutter_test.dart';
import 'package:sqlcool/sqlcool.dart';
import 'base.dart';

Future<void> main() async {
  await setup();

  final db = Db();

  tearDown(log.clear);

  group("init", () {
    test("Init db", () async {
      const schema = """CREATE TABLE item
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
    )""";
      const q = <String>[
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
  });
  group("query", () {
    test("Insert", () async {
      Future<int> insert() async {
        final res =
            await db.insert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

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
      Future<dynamic> upsert() async {
        final res =
            await db.upsert(table: "test", row: {"k": "v"}, verbose: true);
        return res;
      }

      return upsert().then((dynamic r) => expect(r, null));
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

    test("Mjoin", () async {
      Future<List<Map<String, dynamic>>> mJoin() async {
        final res = await db.mJoin(
            table: "test",
            joinsOn: ["table1.id=1"],
            joinsTables: ["table1"],
            where: "id=1",
            verbose: true);
        return res;
      }

      final output = <Map<String, dynamic>>[
        <String, dynamic>{"k": "v"}
      ];
      return mJoin().then((List<Map<String, dynamic>> r) => expect(r, output));
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

    test("Count", () async {
      Future<int> count() async {
        final res = await db.count(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return count().then((int r) => expect(r, 1));
    });

    test("Exists", () async {
      Future<bool> exists() async {
        final res =
            await db.exists(table: "test", where: "id=1", verbose: true);
        return res;
      }

      return exists().then((bool r) => expect(r, true));
    });

    test("Batch insert", () async {
      Future<List<dynamic>> batchInsert() async {
        final res = await db.batchInsert(
            table: "test",
            rows: [
              {"k": "v"},
              {"k2": "v2"}
            ],
            verbose: true);
        return res;
      }

      return batchInsert()
          .then((dynamic r) => expect(r is List<dynamic>, true));
    });
  });

  group("Select bloc", () {
    test("init", () async {
      final bloc = SelectBloc(database: db, reactive: true, table: "test");
      var i = 0;
      bloc.items.listen((item) {
        expect(item, <Map<String, dynamic>>[
          <String, dynamic>{"k": "v"},
          <String, dynamic>{"k": "v"}
        ]);
        if (i > 0) {
          // update finished, dispose
          bloc.dispose();
        }
        ++i;
      });
      bloc.update(<Map<String, dynamic>>[
        <String, dynamic>{"k": "v"},
        <String, dynamic>{"k": "v"}
      ]);
      final bloc2 = SelectBloc(database: db, query: "SELECT * FROM test");
      bloc2.items.listen((item) {
        expect(item, <Map<String, dynamic>>[
          <String, dynamic>{"k": "v"},
          <String, dynamic>{"k": "v"}
        ]);
      });
    });

    test("init with join", () async {
      final bloc = SelectBloc(
          database: db,
          table: "test",
          joinOn: "test_join.id=join.id",
          joinTable: "test_join");
      bloc.items.listen((item) {
        //print("ITEM $item");
        expect(item, <Map<String, dynamic>>[
          <String, dynamic>{"k": "v"}
        ]);
      });
    });
  });
}
