Synchronized map
================

A map that will auto save it's values to the database.

.. highlight:: dart

::

   import 'package:observable/observable.dart';
   import 'package:sqlcool/sqlcool.dart';

   // Define the map with initial data
   var myMap = SynchronizedMap(
      db: db, // an Sqlcool database
      table: "a_table",
      where: "id=1",
      data: ObservableMap.from({"k": "v"}), 
      verbose: true
   );

   // Changing the map will auto update the data in the database:
   myMap.data["k"] = "v2";