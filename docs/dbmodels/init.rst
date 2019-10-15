Declare the model
=================

It is possible to use a mixin to extend a custom model and give it database
interaction methods. This way when querying the database no deserializing and
type casts are needed: only model objects are used

Extend with DbModel
-------------------

.. highlight:: dart

::

    class Car with DbModel {
        String name;
        double price;
    }

Override getters
----------------

::

    class Car with DbModel {
        @override
        int id;

        @override
        Db get db => conf.db;

        @override
        DbTable get table => carTable;
    }

``conf.db`` is the ``Db`` object used. ``carTable`` is the car table schema

Declare a schema
----------------

::

   final carTable = DbTable("car")
      ..varchar("name")
      ..integer("max_speed")
      ..real("price")
      ..integer("year")
      ..boolean("is_4wd", defaultValue: false);

Include this schema in your database initialization call:

::

   db.init(path: "db.sqlite", schema: <DbTable>[carTable]);

Define serializers
------------------

The ``toDb`` serializer and ``fromDb`` deserializer must be defined

::

    class Car with DbModel {
      @override
      Map<String, dynamic> toDb() {
        final row = <String, dynamic>{
          "name": name,
          "max_speed": maxSpeed,
          "price": price,
          "year": year.millisecondsSinceEpoch,
          "is_4wd": is4wd,
          "manufacturer": manufacturer.id
        };
        return row;
      }

      @override
      Car fromDb(Map<String, dynamic> map) {
        final car = Car(
        id: map["id"] as int,
        name: map["name"].toString(),
        maxSpeed: map["max_speed"] as int,
        price: map["price"] as double,
        year: DateTime.fromMillisecondsSinceEpoch(map["year"] as int),
        is4wd: (map["is_4wd"].toString() == "true"),
      );
      return car;
      }
    }
