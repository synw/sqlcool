Batch insert
============

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   rows = <Map<String, String>>[{"name": "one"}, {"name": "two"}];

   await db.batchInsert(
            table: "item",
            rows: rows,
            confligAlgoritm: ConflictAlgorithm.replace)