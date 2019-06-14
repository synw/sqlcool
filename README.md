# Sqlcool

[![pub package](https://img.shields.io/pub/v/sqlcool.svg)](https://pub.dartlang.org/packages/sqlcool) [![Build Status](https://travis-ci.org/synw/sqlcool.svg?branch=master)](https://travis-ci.org/synw/sqlcool) [![Api doc](https://img.shields.io/badge/api-doc-orange.svg)](https://pub.dev/documentation/sqlcool/latest/sqlcool/sqlcool-library.html)

A database helper library for [Sqflite](https://github.com/tekartik/sqflite). Forget about implementation details and focus on the business logic.

- **Simple**: easy api for crud operations
- **Reactive**: stream of changes, select bloc

Check the [documentation](https://sqlcool.readthedocs.io/en/latest/) or the [api doc](https://pub.dev/documentation/sqlcool/latest/sqlcool/sqlcool-library.html) for usage instructions

## Simple crud

### Define the database schema

   ```dart
   import 'package:sqlcool/sqlcool.dart';

   Db db = Db();
   // define the database schema
   DbTable category = DbTable("category")..varchar("name", unique: true);
   DbTable product = DbTable("product")
      ..varchar("name", unique: true)
      ..integer("price")
      ..text("descripton", nullable: true)
      ..foreignKey("category", onDelete: OnDelete.cascade)
      ..index("name");
   List<DbTable> schema = [category, product];
   ```

### Initialize the database

   ```dart
   String dbpath = "db.sqlite"; // relative to the documents directory
   await db.init(path: dbpath, schema: schema).catchError((e) {
     throw("Error initializing the database: ${e.message}");
   });
   ```

### Insert

   ```dart
   Map<String, String> row = {name: "My item",};
   await db.insert(table: "category", row: row).catchError((e) {
     throw("Error inserting data: ${e.message}");
   });
   ```

### Select

   ```dart
   List<Map<String, dynamic>> rows = await db.select(
      table: "product", limit: 20, columns: "id,name",
      where: "name LIKE '%something%'",
      orderBy: "name ASC").catchError((e) {
       throw("Error selecting data: ${e.message}");
   });
   ```

### Update

   ```dart
   int updated = await db.update(table: "category", 
      row: row, where: "id=1").catchError((e) {
         throw("Error updating data: ${e.message}");
   });
   ```

### Delete

   ```dart
   db.delete(table: "category", where: "id=3").catchError((e) {
      throw("Error deleting data: ${e.message}");
   });
   ```

## Reactivity

### Changefeed

A stream of database change events is available

   ```dart
   import 'dart:async';
   import 'package:sqlcool/sqlcool.dart';

   StreamSubscription changefeed;

   changefeed = db.changefeed.listen((change) {
      print("Change in the database:");
      print("Query: ${change.query}");
      if (change.type == DatabaseChange.update) {
        print("${change.value} items updated");
      }
    });
   // Dispose the changefeed when finished using it
   changefeed.cancel();
   ```

### Reactive select bloc

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

## Todo

- [x] Upsert
- [ ] Batch operations
