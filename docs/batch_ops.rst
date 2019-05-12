Batch insert
============

.. highlight:: dart

::

   import 'package:sqflite/sqlflite.dart';
   import 'package:sqlcool/sqlcool.dart';

   var rows = <Map<String, String>>[{"name": "one"}, {"name": "two"}];

   await db.batchInsert(
            table: "item",
            rows: rows,
            confligAlgoritm: ConflictAlgorithm.replace)