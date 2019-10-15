Foreign keys support
====================

The database models support foreign keys

.. highlight:: dart

::

    class Manufacturer with DbModel {
        Manufacturer({this.name});

        final String name;

        @override
        int id;

        @override
        Db get db => conf.db;

        @override
        DbTable get table => manufacturerTable;

        @override
        Map<String, dynamic> toDb() => <String, dynamic>{"name": name};

        @override
        Manufacturer fromDb(Map<String, dynamic> map) =>
            Manufacturer(name: map["name"].toString());
    }

To set a foreign key mention it in your table schema:

::

   final carTable = DbTable("car")
      ..varchar("name")
      ..real("price")
      ..foreign_key("manufacturer");

Update the serializers in the main model to use the foreign key:

::

    class Car with DbModel {
        @override
        Map<String, dynamic> toDb() {
            final row = <String, dynamic>{
                // ...
                "manufacturer": manufacturer.id
            };
        return row;
        }

        @override
        Car fromDb(Map<String, dynamic> map) {
            final car = Car(
                // ...
            );
            // the key will be present only with join queries
            // in a simple select this data is not present
            if (map.containsKey("manufacturer")) {
                car.manufacturer =
                    Manufacturer().fromDb(map["manufacturer"] as Map<String, dynamic>);
            }
            return car;
        }
    }

To perform a join query:

::

    class Car with DbModel {
        static Future<List<Car>> selectRelated({String where, int limit}) async {
            final cars = List<Car>.from(
                await Car().sqlJoin(where: where, limit: limit));
            return cars;
        }
    }

And then use it:


::

    List<Car> cars = await Car.selectRelated(where: "price<50000");
    print(cars[0].manufacturer.name);
