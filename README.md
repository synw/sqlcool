# sqlcool2

[![pub package](https://img.shields.io/pub/v/sqlcool2.svg)](https://pub.dartlang.org/packages/sqlcool2)  [![Build Status](https://travis-ci.org/synw/sqlcool2.svg?branch=master)](https://travis-ci.org/synw/sqlcool2) [![Coverage Status](https://coveralls.io/repos/github/synw/sqlcool2/badge.svg?branch=master&kill_cache=1")](https://coveralls.io/github/synw/sqlcool2?branch=master")

A database helper library for [Sqflite](https://github.com/tekartik/sqflite). Forget about implementation details and focus on the business logic.

- **Simple**: easy api for crud operations
- **Reactive**: stream of changes, select bloc
- **Adaptative**: plug custom models into the database

Check the [documentation](https://sqlcool2.readthedocs.io/en/latest/) or the [api doc](https://pub.dev/documentation/sqlcool2/latest/sqlcool2/sqlcool2-library.html) for usage instructions

## Simple crud

### Define the database schema

   ```dart
   import 'package:sqlcool22/sqlcool22.dart';

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
   try {
     await db.init(path: dbpath, schema: schema);
   } catch(e) {
     rethrow;
   }
   ```

### Insert

   ```dart
   final Map<String, String> row = {name: "My item"};
   try {
     int id = await db.insert(table: "category", row: row)
   } catch(e) {
     rethrow;
   }
   ```

### Select

   ```dart
   try {
     List<Map<String, dynamic>> rows = await db.select(
       table: "product",
       limit: 20,
       columns: "id,name",
       where: "name LIKE '%something%'",
       orderBy: "name ASC",
     );
   } catch (e) {
     rethrow;
   }
   ```

### Update

   ```dart
   try {
     int numRowsUpdated = await db.update(table: "category", 
      row: row, where: "id=1");
   } catch(e) {
     rethrow;
   }
   ```

### Delete

   ```dart
   try {
     await db.delete(table: "category", where: "id=3");
   } catch(e) {
     rethrow;
   }
   ```
   
### Join queries

   ```dart
   try {
     final data = await db.join(
      table: "product",
      columns: "product.name,price,category.name as category_name",
      joinTable: "category",
      joinOn: "product.category=category.id");
   } catch(e) {
     rethrow;
   }
   ```
   
### Join on multiple tables

   ```dart
   try {
     final data = db.mJoin(table: "product", joinsTables: <String>[
      "category",
      "manufacturer"
    ], joinsOn: <String>[
      "product.category=category.id",
      "product.manufacturer=manufacturer.id"
    ]);
   } catch(e) {
     rethrow;
   }
   ```

## Reactivity

### Changefeed

A stream of database change events is available. Inspired by [Rethinkdb](https://rethinkdb.com/)

   ```dart
   import 'dart:async';
   import 'package:sqlcool22/sqlcool22.dart';

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
   import 'package:sqlcool22/sqlcool22.dart';

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

## Database models

*New in 4.0.0*: define models that have database methods. The main
advantage of this is to use only typed model data and avoid the
type conversions from maps for every query. It directly plugs custom
models into the database. Example:

In schema.dart:

   ```dart
   final carTable = DbTable("car")
     ..varchar("name")
     ..integer("max_speed")
     ..real("price")
     ..integer("year")
     ..boolean("is_4wd", defaultValue: false)
     ..foreignKey("manufacturer", onDelete: OnDelete.cascade);

   final manufacturerTable = DbTable("manufacturer")..varchar("name");
   ```

In car_model.dart:

   ```dart
   import 'package:sqlcool22/sqlcool22.dart';
   // the database schema
   import 'schema.dart';
   // another model
   import 'manufacturer_model.dart';

   class Car with DbModel {
     Car(
         {this.id,
         this.name,
         this.maxSpeed,
         this.price,
         this.year,
         this.is4wd,
         this.manufacturer});

     /// define some class properties

     final String name;
     final int maxSpeed;
     final double price;
     final DateTime year;
     final bool is4wd;
     // this is a foreign key to another model
     Manufacturer manufacturer;

     /// [DbModel] required overrides

     @override
     int id;

     /// the [Db] used
     /// pass it your main db
     @override
     Db get db => db;

     /// the table schema representation
     /// check example/pages/dbmodels/schema.dart
     @override
     DbTable get table => carTable;

     /// serialize a row to the database
     @override
     Map<String, dynamic> toDb() {
       // we want the foreign key to be recorded
       assert(manufacturer?.id != null);
       final row = <String, dynamic>{
         "name": name,
         "max_speed": maxSpeed,
         "price": price,
         "year": year.millisecondsSinceEpoch,
         "is_4wd": is4wd,
         "manufacturer": manufacturer.id
       };
       return row;
     }

     /// deserialize a row from database
     @override
     Car fromDb(Map<String, dynamic> map) {
       final car = Car(
         id: map["id"] as int,
         name: map["name"].toString(),
         maxSpeed: map["max_speed"] as int,
         price: map["price"] as double,
         year: DateTime.fromMillisecondsSinceEpoch(map["year"] as int),
         is4wd: (map["is_4wd"].toString() == "true"),
       );
       // the key will be present only with join queries
       // in a simple select this data is not present
       if (map.containsKey("manufacturer")) {
         car.manufacturer =
             Manufacturer().fromDb(map["manufacturer"] as Map<String, dynamic>);
       }
       return car;
     }

     /// Create a static join method for convenience

     static Future<List<Car>> selectRelated({String where, int limit}) async {
       final cars = List<Car>.from(
           await Car().sqlJoin(where: where, limit: limit, verbose: true));
       return cars;
     }
   }
   ```

Then use the models:

   ```dart
  /// car is an instance of [Car]
  await car.sqlInsert();
  await car.sqlUpdate();
  await car.sqlUpsert();
  await car.sqlDelete();
  final cars = Car.selectRelated(where: "speed>200");
  // foreign keys are retrieved as model instances
  print(cars[0].manufacturer.name);
   ```

## Using this

- [Sqlview](https://github.com/synw/sqlview): admin view and infinite list view
- [Kvsql](https://github.com/synw/kvsql): a type safe key/value store
- [Geopoint sql](https://github.com/synw/geopoint_sql): sql operations for geospatial data
