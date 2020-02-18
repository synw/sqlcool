import 'package:flutter_test/flutter_test.dart';
import 'package:sqlcool/sqlcool.dart';

import 'base.dart';
import 'dbmodels/car.dart';
import 'dbmodels/conf.dart';
import 'dbmodels/manufacturer.dart';
import 'dbmodels/schema.dart';

Future<void> main() async {
  await setup();

  await db.init(
      path: "testdb_models.sqlite",
      schema: <DbTable>[carTable, manufacturerTable],
      absolutePath: true);

  tearDown(log.clear);

  test("Init", () async {
    final car = Car(name: "My car", price: 10000.0);
    assert(car.db == db);
    assert(car.table.name == "car");
  });

  test("Mutations", () async {
    // insert
    final car = Car(name: "My car", price: 10000.0);
    car.id = await car.sqlInsert();
    assert(car.id == 1);
    // update
    car.price = 30000;
    await car.sqlUpdate(verbose: true);
    final c = await Car.select(where: "price=30000");
    assert(c.length == 1);
    //print("${c[0].price} / ${car.price}");
    assert(c[0].price == car.price);
    assert(c[0].name == car.name);
    // upsert
    car.price = 40000;
    await car.sqlUpsert();
    final c2 = await Car.select(where: "price=40000");
    assert(c2.length == 1);
    assert(c2[0].price == car.price);
    assert(c2[0].name == car.name);
    // delete
    await car.sqlDelete();
    final c3 = await Car.select(where: 'name="My car"');
    assert(c3.isEmpty);
  });

  test("Foreign keys", () async {
    final manufacturer = Manufacturer(name: "My manufacturer");
    manufacturer.id = await manufacturer.sqlInsert();
    final car = Car(name: "My car", price: 10000.0, manufacturer: manufacturer);
    car.id = await car.sqlInsert();
    print("Car $car / ${car.manufacturer}");
    final cars = await Car.selectRelated();
    print("Query cars: $cars");
    assert(cars.length == 1);
    assert(cars[0].manufacturer.name == "My manufacturer");
  });
}
