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
      path: "testdb.sqlite",
      schema: <DbTable>[table, table1],
      absolutePath: true);

  group("schema", () {
    test("DbTable", () async {
      expect(db.hasSchema, true);
      final t = db.schema.table("table");
      expect(table.name == t.name, true);
      expect(db.schema.hasTable("table"), true);
    });

    test("Db column", () async {
      final col = DatabaseColumn(
          name: "col",
          type: DatabaseColumnType.varchar,
          onDelete: OnDelete.restrict);
      expect(col.typeToString(), "varchar");
      expect(stringToOnDelete("restrict"), OnDelete.restrict);
      expect(onDeleteToString(OnDelete.restrict), "restrict");
    });
  });
}
