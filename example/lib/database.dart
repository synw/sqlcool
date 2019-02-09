import 'package:sqlcool/sqlcool.dart';

saveItem(String itemName) async {
  String table = "items";
  Map<String, String> row = {"name": itemName};
  await db.insert(table: table, row: row, verbose: true).catchError((e) {
    throw (e);
  });
}

deleteItem(String itemName) async {
  String table = "items";
  await db
      .delete(table: table, where: 'name="$itemName"', verbose: true)
      .catchError((e) {
    throw (e);
  });
}

updateItem(String oldItemName, String newItemName) async {
  String table = "items";
  Map<String, String> row = {"name": newItemName};
  await db
      .update(
          table: table, where: 'name="$oldItemName"', row: row, verbose: true)
      .catchError((e) {
    throw (e);
  });
}
