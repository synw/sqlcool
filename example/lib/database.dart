import 'conf.dart';

Future<void> saveItem(String itemName) async {
  final table = "product";
  final row = {
    "name": itemName,
    "category": "1",
    "price": "50",
  };
  await db
      .insert(table: table, row: row, verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}

Future<void> deleteItem(int itemId) async {
  final table = "product";
  await db
      .delete(table: table, where: 'id="$itemId"', verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}

Future<void> updateItem(String oldItemName, String newItemName) async {
  final table = "product";
  final row = {"name": newItemName};
  await db
      .update(
          table: table, where: 'name="$oldItemName"', row: row, verbose: true)
      .catchError((dynamic e) {
    throw (e);
  });
}
