import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
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

  test("Init", () async {
    expect(db.isReady, false);
    await db.select(table: "table").catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
      expect(
          e.message,
          'The Sqlcool database is not ready. This happens when a query' +
              ' is fired and the database has not finished initializing.');
    });
    await db.insert(table: "table", row: <String, String>{}).catchError(
        (dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.upsert(table: "table", row: <String, String>{}).catchError(
        (dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db
        .update(table: "table", row: <String, String>{}, where: "id=1")
        .catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.delete(table: "table", where: "id=1").catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db
        .join(table: "table", joinOn: "", joinTable: "")
        .catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.mJoin(
        table: "table",
        joinsOn: <String>[],
        joinsTables: <String>[]).catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.exists(table: "table", where: "id=1").catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.count(table: "table", where: "id=1").catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    await db.batchInsert(
        table: "table", rows: <Map<String, String>>[]).catchError((dynamic e) {
      expect(e is DatabaseNotReady, true);
    });
    // init
    expect(() async => await db.init(path: null),
        throwsA(predicate<dynamic>((dynamic e) => e is AssertionError)));
    unawaited(db.onReady.then((_) {
      expect(db.isReady, true);
    }));
    await db.init(
        path: "test_errs_db.sqlite",
        schema: <DbTable>[table, table1],
        absolutePath: true,
        debug: true);
    await db.onReady;
    expect(db.isReady, true);
    expect(db.file.path, File("test_errs_db.sqlite").path);
  });
}
