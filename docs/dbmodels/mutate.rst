Data mutations
==============

Once properly declared the model can be modified in the database

Insert
------

.. highlight:: dart

::

    final car = Car(name: "My car", price: 25000.0);
    car.sqlInsert();


Update
------

::

    car.price = 23000.0;
    car.sqlUpdate();

Upsert
------

::

    car.name = "My new car name";
    car.sqlUpsert();

Delete
------

::

    car.sqlDelete();


The query parameters are the same than for regular queries: check the database
operations section for details


