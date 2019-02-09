# Sqlcool

A database helper class for [Sqflite](https://github.com/tekartik/sqflite): forget about implementation details and focus on the business logic

Check the [documentation](https://sqlcool.readthedocs.io/en/latest/) for usage instructions

   ```yaml

   dependencies:
     sqlcool: ^1.1.2
   ```

## Quick example

### Simple crud

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

### Reactive select bloc

The bloc will rebuild itself on any database change.

   ```dart
   import 'package:flutter/material.dart';
   import 'package:sqlcool/sqlcool.dart';

   class _PageSelectBlocState extends State<PageSelectBloc> {
     SelectBloc bloc;

     @override
     void initState() {
       super.initState();
       this.bloc = SelectBloc(
           table: "items", orderBy: "name", reactive: true, verbose: true);
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text("My app"),
         ),
         body: StreamBuilder<List<Map>>(
             stream: bloc.items,
             builder: (BuildContext context, AsyncSnapshot snapshot) {
               if (snapshot.hasData) {
                 // the select query has not found anything
                 if (snapshot.data.length == 0) {
                   return Center(
                     child: Text(
                         "No data"),
                   );
                 }
                 // the select query has results
                 return ListView.builder(
                     itemCount: snapshot.data.length,
                     itemBuilder: (BuildContext context, int index) {
                       var item = snapshot.data[index];
                       return ListTile(
                         title: GestureDetector(
                           child: Text(item["name"]),
                           onTap: () => print("Action"),
                         ),
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

- [ ] Upsert
- [ ] Batch operations