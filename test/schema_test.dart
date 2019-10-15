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

  test("DbTable", () async {
    expect(db.hasSchema, true);
    var t = db.schema.table("table");
    expect(table.name == t.name, true);
    expect(db.schema.hasTable("table"), true);
    final fkCol = DbColumn(
        name: "table1", type: DbColumnType.integer, onDelete: OnDelete.cascade);
    expect(t.foreignKeys[0].type, fkCol.type);
    expect(t.foreignKeys[0].name, fkCol.name);
    expect(t.foreignKeys[0].onDelete, fkCol.onDelete);
    t = db.schema.table("table1");
    final col = DbColumn(name: "name", type: DbColumnType.varchar);
    expect(t.column("name").name, "name");
    expect(t.columns[0].name, col.name);
    expect(t.columns[0].type, col.type);
    expect(t.columns[0].name, col.name);
    expect(t.columns[0].type, col.type);
  });

  test("Db column", () async {
    var col = DbColumn(name: "col", type: DbColumnType.varchar);
    expect(col.typeToString(), "varchar");
    col = DbColumn(name: "col", type: DbColumnType.integer);
    expect(col.typeToString(), "integer");
    col = DbColumn(name: "col", type: DbColumnType.real);
    expect(col.typeToString(), "real");
    col = DbColumn(name: "col", type: DbColumnType.text);
    expect(col.typeToString(), "text");
    col = DbColumn(name: "col", type: DbColumnType.boolean);
    expect(col.typeToString(), "boolean");
    col = DbColumn(name: "col", type: DbColumnType.blob);
    expect(col.typeToString(), "blob");
    expect(stringToOnDelete("restrict"), OnDelete.restrict);
    expect(onDeleteToString(OnDelete.restrict), "restrict");
    expect(stringToOnDelete("cascade"), OnDelete.cascade);
    expect(onDeleteToString(OnDelete.cascade), "cascade");
    expect(stringToOnDelete("set_null"), OnDelete.setNull);
    expect(onDeleteToString(OnDelete.setNull), "set_null");
    expect(stringToOnDelete("set_default"), OnDelete.setDefault);
    expect(onDeleteToString(OnDelete.setDefault), "set_default");
    expect(db.schema.table("table").hasColumn("name"), true);
  });

  test("describe", () async {
    final col = DbColumn(name: "col", type: DbColumnType.varchar);
    final des = col.describe(isPrint: false);
    expect(des, """Column col:
 - Type: DbColumnType.varchar
 - Unique: false
 - Nullable: false
 - Default value: null
 - Is foreign key: false
 - Reference: null
 - On delete: null""");
  });
}
