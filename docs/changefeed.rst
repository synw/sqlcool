Reactivity
==========

Changefeed
----------

A changefeed is available (inspired by `Rethinkdb
<https://www.rethinkdb.com/>`_).
It's a stream that will notify about any change in 
the database.

.. highlight:: dart

::

   import 'dart:async';
   import 'package:flutter/material.dart';
   import 'package:sqlcool/sqlcool.dart';
   import 'dialogs.dart';

   class _PageState extends State<Page> {
     StreamSubscription _changefeed;

     @override
     void initState() {
        _changefeed = db.changefeed.listen((change) {
         print("CHANGE IN THE DATABASE:");
         print("Change type: ${change.type}");
         print("Number of items impacted: ${change.value}");
         print("Query: ${change.query}");
         if (change.type == DatabaseChange.update) {
           print("${change.value} items updated");
         }
       });
       super.initState();
     }

     @override
     void dispose() {
       _changefeed.cancel();
       super.dispose();
     }

     // ...
   }

   class Page extends StatefulWidget {
     @override
     _PageState createState() => _PageState();
   }


Reactive select bloc
--------------------

A ``SelectBloc`` can take a ``reactive`` parameter. If it is ``true`` the bloc
will automatically rebuild itself on any database change

Check the `example
<https://github.com/synw/sqlcool/tree/master/example>`_ for usage demo.