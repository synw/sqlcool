# Sqlcool

[![pub package](https://img.shields.io/pub/v/sqlcool.svg)](https://pub.dartlang.org/packages/sqlcool) [![Build Status](https://travis-ci.org/synw/sqlcool.svg?branch=master)](https://travis-ci.org/synw/sqlcool)

A database helper library for [Sqflite](https://github.com/tekartik/sqflite). Forget about implementation details and focus on the business logic.

- **Simple**: easy api for crud operations
- **Reactive**: stream of changes, auto updated bloc, synchronized map

Check the [documentation](https://sqlcool.readthedocs.io/en/latest/) for usage instructions

## Simple crud

   ```dart
   import 'package:sqlcool/sqlcool.dart';

   Db db = Db();
   // define the database schema
   DbTable category = DbTable("category")..varchar("name", unique: true);
   DbTable product = DbTable("product")
      ..varchar("name", unique: true)
      ..integer("price")
      ..foreignKey("category", onDelete: OnDelete.cascade)
      ..index("name");
   List<String> initQueries = category.queries..addAll(product.queries);
   // initialize the database
   String dbpath = "db.sqlite"; // relative to the documents directory
   await db.init(path: dbpath, queries: initQueries).catchError((e) {
     throw("Error initializing the database: ${e.message}");
   });
   // insert
   Map<String, String> row = {name: "My item",};
   await db.insert(table: "category", row: row).catchError((e) {
     throw("Error inserting data: ${e.message}");
   });
   // select
   List<Map<String, dynamic>> rows = await db.select(
      table: "product", limit: 20, columns: "id,name",
      where: "name LIKE '%something%'",
      orderBy: "name ASC").catchError((e) {
       throw("Error selecting data: ${e.message}");
   });
   //update
   int updated = await db.update(table: "category", 
      row: row, where: "id=1").catchError((e) {
         throw("Error updating data: ${e.message}");
   });
   // delete
   db.delete(table: "category", where: "id=3").catchError((e) {
      throw("Error deleting data: ${e.message}");
   });
   ```

## Changefeed

A stream of database change events is available

   ```dart
   import 'dart:async';
   import 'package:sqlcool/sqlcool.dart';

   StreamSubscription changefeed;

   changefeed = db.changefeed.listen((change) {
      print("Change in the database:");
      throw("Query: ${change.query}");
      if (change.type == DatabaseChange.update) {
        print("${change.value} items updated");
      }
    });
   // Dispose the changefeed when finished using it
   changefeed.cancel();
   ```

## Reactive select bloc

The bloc will rebuild itself on any database change because of the `reactive`
parameter set to `true`:

   ```dart
   import 'package:flutter/material.dart';
   import 'package:sqlcool/sqlcool.dart';

   class _PageSelectBlocState extends State<PageSelectBloc> {
     SelectBloc bloc;

     @override
     void initState() {
       super.initState();
       this.bloc = SelectBloc(
           table: "items", orderBy: "name", reactive: true);
     }

     @override
     void dispose() {
       bloc.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text("My app")),
         body: StreamBuilder<List<Map>>(
             stream: bloc.items,
             builder: (BuildContext context, AsyncSnapshot snapshot) {
               if (snapshot.hasData) {
                 // the select query has not found anything
                 if (snapshot.data.length == 0) {
                   return Center(child: const Text("No data"));
                 }
                 // the select query has results
                 return ListView.builder(
                     itemCount: snapshot.data.length,
                     itemBuilder: (BuildContext context, int index) {
                       var item = snapshot.data[index];
                       return ListTile(
                         title: GestureDetector(
                           child: Text(item["name"]),
                           onTap: () => someFunction()),
                       );
                     });
               } else {
                 // the select query is still running
                 return CircularProgressIndicator();
               }
             }),
       );
     }
   }

   class PageSelectBloc extends StatefulWidget {
     @override
     _PageSelectBlocState createState() => _PageSelectBlocState();
   }
   ```

## Synchronized map

A map that auto saves it's values to the database. Useful for values that
are often updated, like persistant app state

   ```dart
   import 'package:sqlcool/sqlcool.dart';

   var myMap = SynchronizedMap(
      db: db,
      table: "a_table",
      where: "id=1",
      columns = "col1,col2,col3"
   );

   // Wait until the map is initialized
   await myMap.onReady;

   // Changing the map will auto update the data in the database:
   myMap.data["col1"] = "value";

   // Dispose the map when finished using
   myMap.dispose();
   ```

## Todo

- [x] Upsert
- [ ] Batch operations
