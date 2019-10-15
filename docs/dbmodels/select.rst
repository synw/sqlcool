Select operations
=================

The select calls are done via an instance of the model. The recommended method
is to define some select static methods in your model:

.. highlight:: dart

::

    class Car with DbModel {
        static Future<List<Car>> select({String where, int limit}) async {
            final cars = List<Car>.from(
                await Car().sqlSelect(where: where, limit: limit));
            return cars;
        }
    }

And then use it:


::

    List<Car> cars = await Car.select(where: "price<50000");
