import 'dart:async';
import 'models/car.dart';
import 'models/manufacturer.dart';
import '../../conf.dart';

Future<void> populateDb() async {
  final n = await db.count(table: "car");
  final hasData = (n > 0);
  if (hasData) {
    print("Car table has data");
    return;
  }
  print("Populating cars table");
  final m1 = Manufacturer(name: "Fiat");
  final m2 = Manufacturer(name: "General Motors");
  m1.id = await m1.sqlInsert(verbose: true);
  m2.id = await m2.sqlInsert(verbose: true);
  final c1 = Car(
      name: "Car 1",
      price: 13000.0,
      maxSpeed: 200,
      year: DateTime.now().subtract(Duration(days: (360 * 5))),
      is4wd: true,
      manufacturer: m1);
  final c2 = Car(
      name: "Car 2",
      price: 15000.0,
      maxSpeed: 220,
      is4wd: false,
      year: DateTime.now().subtract(Duration(days: (360 * 3))),
      manufacturer: m1);
  final c3 = Car(
      name: "Car 3",
      price: 23000.0,
      maxSpeed: 260,
      is4wd: false,
      year: DateTime.now().subtract(Duration(days: 360)),
      manufacturer: m2);
  await c1.sqlInsert(verbose: true);
  await c2.sqlInsert(verbose: true);
  await c3.sqlInsert(verbose: true);
}
