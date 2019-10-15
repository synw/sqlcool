import 'package:flutter_test/flutter_test.dart';
import 'package:sqlcool/sqlcool.dart';
import 'base.dart';

void main() async {
  await setup();

  final db = Db();
  final table1 = DbTable("table1")..varchar("name");
  final table = DbTable("table")
    ..varchar("name", unique: true, nullable: true)
    ..integer("int", defaultValue: 3, unique: true, check: "int>1")
    ..real("real")
    ..boolean("bool", defaultValue: true)
    ..blob("blob")
    ..text("text")
    ..index("name")
    ..timestamp()
    ..foreignKey("table1", unique: false, onDelete: OnDelete.cascade)
    ..uniqueTogether("name", "int");

  await db.init(
      path: "test_changefeed_db.sqlite",
      schema: <DbTable>[table, table1],
      absolutePath: true,
      debug: true);

  test("Listen", () async {
    db.changefeed.listen((change) {
      switch (change.type) {
        case DatabaseChange.insert:
          expect(change.value, 1);
          expect(change.toString().startsWith("""1 item inserted
DatabaseChange.insert : 1
INSERT INTO test (k) VALUES(?) {k: v} in """), true);
          break;
        case DatabaseChange.delete:
          expect(change.value, 1);
          break;
        case DatabaseChange.update:
          expect(change.value, 1);
          break;
        default:
      }
      //print("\n\n$change\n\n");
    });
    await db.insert(table: "test", row: {"k": "v"}, verbose: true);
    await db.update(
        table: "test", row: {"k": "v"}, where: 'name="k"', verbose: true);
    await db.delete(table: "test", where: 'name="k"', verbose: true);
  });
}
