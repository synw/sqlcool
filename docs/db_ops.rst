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
   await db.insert(table: "category", row: row, verbose: true);

Required parameters:

:table: *String* name of the table, required
:row: *Map<String, String>* data, required

Optional parameter:

:verbose: *bool* ``true`` or ``false``

Select
------

::

   import 'package:sqlcool/sqlcool.dart';

   List<Map<String, dynamic>> rows =
      await db.select(table: "product", limit: 20, where: "name LIKE '%something%'",
         orderBy: "price ASC");

Required parameter:

:table: *String* name of the table, required

Optional parameters:

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

   Map<String, String> row = {
       slug: "my-item-new",
       name: "My item new",
   }
   int updated = await db.update(table: category, row: row, where: "id=1", verbose: true);

Required parameters:

:table: *String* name of the table, required
:row: *Map<String, String>* data, required

Optional parameters:

:where: *String* the where sql clause
:verbose: *bool* ``true`` or ``false``


Delete
------

::

   import 'package:sqlcool/sqlcool.dart';

   await db.delete(table: "category", where: "id=1");

Required parameters:

:table: *String* name of the table, required
:where: *String* the where sql clause

Optional parameter:

:verbose: *bool* ``true`` or ``false``

Join
----

::

   import 'package:sqlcool/sqlcool.dart';

   List<Map<String, dynamic>> rows = await db.join(
                   table: product, offset: 10, limit: 20,
                   columns: "id, name, price, category.name as category_name",
                   joinTable: "category",
                   joinOn: "product.category=category.id");


Required parameter:

:table: *String* name of the table, required

Optional parameters:

:columns: *String* the select sql clause
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

   bool exists = await db.exists(table: "category", "id=3");

Required parameters:

:table: *String* name of the table, required
:where: *String* the where sql clause
