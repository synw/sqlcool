Initialize database
===================

Initialize an empty database
----------------------------

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   Db db = Db();

   void myInit() {
      String q1 = """CREATE TABLE category (
         id INTEGER PRIMARY KEY,
         name TEXT NOT NULL
      )""";
      String q2 = """CREATE TABLE product (
         id INTEGER PRIMARY KEY,
         name TEXT NOT NULL,
         price REAL NOT NULL,
         category_id INTEGER,
         CONSTRAINT category
            FOREIGN KEY (category_id) 
            REFERENCES category(id) 
            ON DELETE CASCADE
      )""";
      String dbpath = "data.sqlite";
      List<String> queries = [q1, q2];
      db.init(path: dbpath, queries: queries, verbose: true).catchError((e) {
          print("Error initializing the database: $e");
      }).then((_){ print("Database is ready"; });
   }

Required parameters:

:path: *String* path where the database file will be stored:
   relative to the documents directory path

Optional parameter:

:queries: *List<String>* queries to run at database creation
:fromAsset: *String* path to the Sqlite asset file, relative to the
   documents directory
:verbose: *bool* ``true`` or ``false``

The database is created in the documents directory.
The create table queries will run once on database file creation.

Initialize a database from an Sqlite asset file
-----------------------------------------------

::

   void main() {
      String dbpath = "data.sqlite";
      db.init(path: dbpath, fromAsset: "assets/data.sqlite", verbose: true).catchError((e) {
          print("Error initializing the database; $e");
      });
   }

Multiple databases
------------------

::

   import 'package:sqlcool/sqlcool.dart';

   void main() {
      db1 = Db();
      db2 = Db();
      // ...
   }

Verbosity
---------

The ``Db`` methods have a ``verbose`` option that will print the query. To get more
detailled information and queries results you can activate the Sqflite debug mode:


::

   db.init(path: dbpath, queries: [q], debug: true);