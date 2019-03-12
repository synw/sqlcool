import 'conf.dart';

Future<void> saveItem(String itemName) async {
  String table = "product";
  Map<String, String> row = {
    "name": itemName,
    "category_id": "1",
    "price": "50",
  };
  await db
      .insert(table: table, row: row, verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}

Future<void> deleteItem(int itemId) async {
  String table = "product";
  await db
      .delete(table: table, where: 'id="$itemId"', verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}

Future<void> updateItem(String oldItemName, String newItemName) async {
  String table = "product";
  Map<String, String> row = {"name": newItemName};
  await db
      .update(
          table: table, where: 'name="$oldItemName"', row: row, verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}
