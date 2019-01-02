# Sqlcool

A database helper class for [Sqflite](https://github.com/tekartik/sqflite).

Check the [documentation]() for usage instructions

## Quick example

   ```dart
   import 'package:sqlcool/sqlcool.dart';

   void main() {
      String q = """CREATE TABLE category (
         id INTEGER PRIMARY KEY,
         slug TEXT UNIQUE NOT NULL,
         name TEXT NOT NULL
         )""";
      String dbpath = "data.sqlite";
      List<String> queries = [q];
      db.init(dbpath, queries: queries, verbose: true).catchError((e) {
          print("Error initializing the database: $e");
      });
	  // insert data
      Map<String, String> row = {
       slug: "my-item",
       name: "My item",
      }
      String table = "category";
      await db.insert(table, row, verbose: true);
	  // select data
      List<Map<String, dynamic>> rows =
        await db.select(table, limit: 20, where: "name LIKE '%something%'",
           orderBy: "name ASC");
   }
   ```

## Todo

- [ ] Better error handling
- [ ] Upsert