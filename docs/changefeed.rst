Reactivity
==========

A changefeed is available (inspired by `Rethinkdb
<https://www.rethinkdb.com/>`_).
It's a stream that will notify about any change in 
the database.

Changefeed
----------

.. highlight:: dart

::

   StreamSubscription _changefeed;

   _changefeed = database.changefeed.listen((change) {
      _getItems();
      if (verbose) {
         print("CHANGE IN THE DATABASE: $change");
         print("Change type: ${change.type}");
         print("Number of items that changed: ${change.value}");
      }
   });

Reactive select bloc
--------------------

A ``SelectBloc`` can take a ``reactive`` parameter. If it is ``true`` the bloc
will automatically rebuild itself on any database change

Check the `example
<https://github.com/synw/sqlcool/tree/master/example>`_ for usage demo.