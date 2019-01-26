# Sqlcool

A database helper class for [Sqflite](https://github.com/tekartik/sqflite): forget about implementation details and focus on the business logic

Check the [documentation](https://sqlcool.readthedocs.io/en/latest/) for usage instructions

## Quick example

   ```dart
   import 'package:sqlcool/sqlcool.dart';

   void someFunc() async {
      String dbpath = "db.sqlite"; // relative to the documents directory
      await db.init(path: dbpath, fromAsset: "assets/db.sqlite", verbose: true).catchError((e) {
          print("Error initializing the database: ${e.message}");
      });
      // insert
      Map<String, String> row = {
       slug: "my-item",
       name: "My item",
      };
      db.insert(table: "category", row: row, verbose: true).catchError((e) {
          print("Error inserting data: ${e.message}");
      });
      // select
      List<Map<String, dynamic>> rows = await db.select(
        table: "product", limit: 20, columns: "id,name",
        where: "name LIKE '%something%'",
        orderBy: "name ASC").catchError((e) {
          print("Error selecting data: ${e.message}");
      });
      //update
      Map<String, String> row = {
       slug: "my-item-new",
       name: "My item new",
      };
      int updated = await db.update(table: "category", 
          row: row, where: "id=1", verbose: true).catchError((e) {
             print("Error updating data: ${e.message}");
      });
      // delete
      db.delete(table: "category", where: "id=3").catchError((e) {
          print("Error deleting data: ${e.message}");
      });
   }
   ```

## Todo

- [ ] Upsert
- [ ] Batch operations