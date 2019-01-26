Using the bloc pattern for select
=================================

A stream builder is available for select bloc

List stream builder
-------------------

.. highlight:: dart

::

   import 'package:flutter/material.dart';
   import 'package:sqlcool/sqlcool.dart';

   class _ProductsPageState extends State<ProductsPage> {
        SelectBloc bloc;

        _ProductsPageState();

        @override
        void initState() {
            super.initState();
            this.bloc = SelectBloc(table: "product",
                limit: 20,
                order_by: "name");
        }

        @override
        void dispose() {
            this.bloc.dispose();
            super.dispose();
        }

        @override
        Widget build(BuildContext context) {
            return StreamBuilder<List<Map>>(
               stream: bloc.items,
               // ....
               );
        }
    }

    class ProductsPage extends StatefulWidget {
        @override
        _ProductsPageState createState() => _ProductsPageState();
    }


``SelectBloc`` class:

Required parameter:

:table: *String* name of the table, required

Optional parameters:

:select: *String* the select sql clause
:where: *String* the where sql clause
:joinTable: *String* join table name
:joinOn: *String* join on sql clause
:orderBy: *String* the sql order_by clause
:limit: *int* the sql limit clause
:offset: *int* the sql offset clause
:verbose: *bool* ``true`` or ``false``
:db: *Db* the database to use: default is the default database

Join queries
------------

::

   @override
   void initState() {
      super.initState();
      this.bloc = SelectBloc(table: "product", offset: 10, limit: 20,
                             select: "id, name, price, category.name as category_name",
                             joinTable: "category",
                             joinOn: "product.category=category.id");
   }
