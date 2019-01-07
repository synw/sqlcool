Database operations
===================

Insert
------

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   Map<String, String> row = {
       slug: "my-item",
       name: "My item",
   }
   String table = "category";
   await db.insert(table, row, verbose: true);

Required positional parameters:

:table: *String* name of the table, required
:row: *Map<String, String>* data, required

Optional named parameter:

:verbose: *bool* ``true`` or ``false``

Select
------

::

   import 'package:sqlcool/sqlcool.dart';

   String table = "product";
   List<Map<String, dynamic>> rows =
      await db.select(table, limit: 20, where: "name LIKE '%something%'",
         orderBy: "price ASC");

Required positional parameter:

:table: *String* name of the table, required

Optional named parameters:

:columns: *String* the columns to select: default is `"*"`
:where: *String* the where sql clause
:orderBy: *String* the sql order_by clause
:limit: *int* the sql limit clause
:offset: *int* the sql offset clause
:verbose: *bool* ``true`` or ``false``

Update
------

::

   import 'package:sqlcool/sqlcool.dart';

   String table = "category";
   Map<String, String> row = {
       slug: "my-item-new",
       name: "My item new",
   }
   String where = "id=1";
   int updated = await db.update(table, row, where, verbose: true);

Required positional parameters:

:table: *String* name of the table, required
:row: *Map<String, String>* data, required

Optional named parameters:

:where: *String* the where sql clause
:verbose: *bool* ``true`` or ``false``


Delete
------

::

   import 'package:sqlcool/sqlcool.dart';

   String table = "category";
   String where = "id=1";
   await db.delete(table, where);

Required positional parameters:

:table: *String* name of the table, required
:where: *String* the where sql clause

Optional named parameter:

:verbose: *bool* ``true`` or ``false``

Join
----

::

   import 'package:sqlcool/sqlcool.dart';

   String table = "product";
   List<Map<String, dynamic>> rows = await db.join(
                   table, offset: 10, limit: 20,
                   select: "id, name, price, category.name as category_name",
                   joinTable: "category",
                   joinOn: "product.category=category.id");


Required positional parameter:

:table: *String* name of the table, required

Optional named parameters:

:select: *String* the select sql clause
:where: *String* the where sql clause
:joinTable: *String* join table name
:joinOn: *String* join on sql clause
:orderBy: *String* the sql order_by clause
:limit: *int* the sql limit clause
:offset: *int* the sql offset clause
:verbose: *bool* ``true`` or ``false``

Exists
------

::

   import 'package:sqlcool/sqlcool.dart';

   String table = "category";
   bool exists = await db.exists(table, "id=3");

Required positional parameters:

:table: *String* name of the table, required
:where: *String* the where sql clause
