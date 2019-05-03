Synchronized map
================

A map that will auto save it's values to the database.

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   // Define the map with initial data
   var myMap = SynchronizedMap(
      db: db, // an Sqlcool database
      table: "a_table",
      where: "id=1",
      columns = "col1,col2,col3", 
      verbose: true
   );

   // Wait until the map is initialized
   await myMap.onReady;

   // Changing the map will auto update the data in the database:
   myMap.data["col1"] = "value";

   // Dispose the map when finished using
   myMap.dispose();