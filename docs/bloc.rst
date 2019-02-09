Using the bloc pattern for select
=================================

A `SelectBloc` is available to use the bloc pattern.

Select bloc
-----------

.. highlight:: dart

::

   import 'package:flutter/material.dart';
   import 'package:sqlcool/sqlcool.dart';

   class _PageSelectBlocState extends State<PageSelectBloc> {
     SelectBloc bloc;

     @override
     void initState() {
       super.initState();
       this.bloc = SelectBloc(
           table: "items", orderBy: "name", verbose: true);
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
                         "No data. Use the + in the appbar to insert an item"),
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

``SelectBloc`` class:

Required parameter:

:table: *String* name of the table, required

Optional parameters:

:select: *String* the select sql clause
:where: *String* the where sql clause
:joinTable: *String* join table name
:joinOn: *String* join on sql clause
:orderBy: *String* the sql order_by clause
:limit: *int* the sql limit clause
:offset: *int* the sql offset clause
:reactive: *bool* if `true` the select bloc will react to database changes. Defaults to `false`
:verbose: *bool* ``true`` or ``false``
:database: *Db* the database to use: default is the default database

Join queries
------------

::

   @override
   void initState() {
      super.initState();
      this.bloc = SelectBloc(table: "product", offset: 10, limit: 20,
                             select: "id, name, price, category.name as category_name",
                             joinTable: "category",
                             joinOn: "product.category=category.id");
   }
