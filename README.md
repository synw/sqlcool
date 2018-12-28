# Sqlcool

A database helper class for [Sqflite](https://github.com/tekartik/sqflite).

## Usage

### Initialize an empty database

   ```dart
   import 'package:sqlcool/sqlcool.dart';


   void main() {
      String q1 = """CREATE TABLE category (
         id INTEGER PRIMARY KEY,
         slug TEXT UNIQUE NOT NULL,
         name TEXT
         )""";
      String q2 = """CREATE TABLE product (
         id INTEGER PRIMARY KEY,
         price REAL NULL,
         date INTEGER,
         category INTEGER
         )""";
      String dbpath = "data.sqlite";
      List<String> queries = [q1, q2];
      await db.init(dbpath, queries: queries, verbose: true);
   }
   ```

The database is created in the documents directory. The create table queries will run once on database file creation.

### Initialize a database from an Sqlite asset file

   ```dart
   import 'package:sqlcool/sqlcool.dart';


   void main() {
      String dbpath = "data.sqlite";
      await db.init(dbpath, fromAsset: "assets/data.sqlite", verbose: true);
   }
   ```

## Database operations

### Insert

   ```dart
   import 'package:sqlcool/sqlcool.dart';
   
   Map<String, String> row = {
       slug: "my-item",
       name: "My item",
   }
   String table = "category";
   await db.insert(table, row, verbose: true);
   ```

### Select

   ```dart
   import 'package:sqlcool/sqlcool.dart';
   
   String table = "category";
   await db.select(table, offset: 10, limit: 20, where: "id=1");
   ```

### Update

   ```dart
   import 'package:sqlcool/sqlcool.dart';
   
   String table = "category";
   Map<String, String> row = {
       slug: "my-item-new",
       name: "My item new",
   }
   String where = "id=1";
   int updated = await db.update(table, row, where, verbose: true);
   ```

### Delete

   ```dart
   import 'package:sqlcool/sqlcool.dart';
   
   String table = "category";
   String where = "id=1";
   await db.delete(table, where);
   ```

## Using the bloc pattern for select

A stream controller is available for select blocs:

   ```dart
   import 'package:sqlcool/sqlcool.dart';
   
   class _CategoriesPageState extends State<CategoriesPage> {
      SelectBloc bloc;

      _CategoriesPageState();

      @override
      void initState() {
         super.initState();
         // select the data
         this.bloc = SelectBloc("category", offset: 10, limit: 20);
      }

      @override
      void dispose() {
         this.bloc.dispose();
         super.dispose();
      }
   }

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         body: StreamBuilder<List<Map<String, dynamic>>>(
         stream: this.bloc.items,
         builder: (BuildContext context,
             AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                 if (snapshot.hasData) {
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                         Map<String, dynamic> item = snapshot.data[index];
                         // ....
                         // ....
                    }
                 }
             }
       }));
   }
   ```

## Todo

- [ ] Better error handling
- [ ] Upsert