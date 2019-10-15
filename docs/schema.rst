Schema definition
=================

Columns
-------

.. highlight:: dart

::

   DbTable category = DbTable("category")..varchar("name", unique: true);
   DbTable product = DbTable("product")
      ..varchar("name", unique: true)
      ..integer("price")
     ..real("number")
     ..boolean("bool", defaultValue: true)
     ..text("description")
     ..blob("blob")
     ..timestamp()
      ..foreignKey("category", onDelete: OnDelete.cascade);

Parameters for the column constructors:

:name: *String* the name of the column

Optional parameters:

:unique: *bool* if the column must be unique
:nullable: *bool* if the column can be null
:defaultValue: *dynamic* (depending on the row type: integer if
 the row is integer for example) the default value of a column
:check: *String* a check constraint: ex: 

::

   DbTable("table")..integer("intname", check="intname>0");

Note: the foreignKey must be placed after the other fields definitions

Create an index on a column:

 ::

   DbTable("table")
      ..varchar("name")
      ..index("name");

Unique together constraint:

 ::

   DbTable("table")
      ..varchar("name")
      ..integer("number")
      ..uniqueTogether("name", "number");

Methods
-------

Initialize the database with a schema:

::

   db.init(path: "mydb.sqlite", schema: <DbTable>[category, product]);

Check if the database has a schema:

::

   final bool hasSchema = db.hasSchema()  // true or false;

Get a table schema:

::

   final DbTable productSchema = db.schema.table("product");

Check if a table is in the schema:

::

   final bool tableExists = db.schema.hasTable("product");

Check if a table has a column:

::

   final bool columnExists = db.schema.table("product").hasColumn("name");
