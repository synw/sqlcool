Initialize database
===================

Initialize an empty database
----------------------------

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   void main() {
      String q1 = """CREATE TABLE product (
         id INTEGER PRIMARY KEY,
         name TEXT NOT NULL,
         price REAL NOT NULL,
         category INTEGER FOREIGN KEY (category) REFERENCES category(id)
         )""";
      String q2 = """CREATE TABLE category (
         id INTEGER PRIMARY KEY,
         name TEXT NOT NULL
         )""";
      String dbpath = "data.sqlite";
      List<String> queries = [q1, q2];
      db.init(path: dbpath, queries: queries, verbose: true).catchError((e) {
          print("Error initializing the database: $e");
      });
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

The ``db`` object is an instance of the ``Db`` class. You can instantiate
it yourself if you want to use multiple databases or to have full
control over the instance(s):

::

   import 'package:sqlcool/sqlcool.dart';

   void main() {
      db1 = Db();
      db2 = Db();
      // ...
   }
