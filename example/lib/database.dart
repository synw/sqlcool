import 'package:sqlcool2/sqlcool2.dart';

import 'conf.dart';

const table = "product";

Future<void> saveItem(String itemName) async {
  final row = DbRow(<DbRecord<dynamic>>[
    DbRecord<String>("name", itemName),
    DbRecord<int>("category", 1),
    DbRecord<int>("price", 50),
  ]);
  await db
      .insert(table: table, row: row, verbose: true)
      .catchError((dynamic e) {
    throw e;
  });
}

Future<void> deleteItem(int itemId) async {
  await db
      .delete(table: table, where: 'id="$itemId"', verbose: true)
      .catchError((dynamic e) {
    throw e;
  });
}

Future<void> updateItem(String oldItemName, String newItemName) async {
  final row = DbRow.fromRecord(DbRecord<String>("name", newItemName));
  await db
      .update(
          table: table, where: 'name="$oldItemName"', row: row, verbose: true)
      .catchError((dynamic e) {
    throw e;
  });
}
