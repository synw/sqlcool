Initialize database
===================

Schema definition
-----------------

.. highlight:: dart

::

   DbTable category = DbTable("category")..varchar("name", unique: true);
   DbTable product = DbTable("product")
      ..varchar("name", unique: true)
      ..integer("price")
      ..foreignKey("category", onDelete: OnDelete.cascade)
      ..index("name");

Parameters for the column constructors:

:name: *String* the name of the column

Optional parameters:

:unique: *bool* if the column must be unique
:nullable: *bool* if the column can be null
:defaultValue: *String* the default value of a column

Initialize an empty database
----------------------------

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   Db db = Db();

   // either use the schema definition constructor
   // or define the tables by hand
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
      // the path is relative to the documents directory
      String dbpath = "data.sqlite";
      List<String> queries = [q1, q2];
      db.init(path: dbpath, queries: queries, verbose: true).catchError((e) {
          throw("Error initializing the database: $e");
      });
   }

   void main() {
      /// initialize the database async. Use the [onReady]
      /// callback later to react to the initialization completed event
     myInit();
     runApp(MyApp());
   }

   // then later check if the database is ready

   @override
   void initState() {
      db.onReady.then((_) {
         setState(() {
            print("STATE: THE DATABASE IS READY");
         });
      });
   super.initState();
   }

Required parameters for ``init``:

:path: *String* path where the database file will be stored:
   relative to the documents directory path

Optional parameter:

:sqfliteDatabase: *Database* an optional existing Sqflite database
:queries: *List<String>* queries to run at database creation
:fromAsset: *String* path to the Sqlite asset file, relative to the
   documents directory
:absolutePath: *bool* if `true` the provided path will not be relative to the 
documents directory and taken as absolute
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