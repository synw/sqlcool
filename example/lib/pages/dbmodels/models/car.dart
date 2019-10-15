import 'package:sqlcool/sqlcool.dart';
import '../../../conf.dart' as conf;
import '../schema.dart';
import 'manufacturer.dart';

class Car with DbModel {
  Car(
      {this.id,
      this.name,
      this.maxSpeed,
      this.price,
      this.year,
      this.is4wd,
      this.manufacturer});

  /// define some class properties

  final String name;
  final int maxSpeed;
  final double price;
  final DateTime year;
  final bool is4wd;
  Manufacturer manufacturer;

  /// [DbModel] required overrides

  @override
  int id;

  /// the [Db] used
  @override
  Db get db => conf.db;

  /// the table schema representation
  /// check example/pages/dbmodels/schema.dart
  @override
  DbTable get table => carTable;

  /// serialize a row to the database
  @override
  Map<String, dynamic> toDb() {
    // we want the foreign key to be recorded
    assert(manufacturer?.id != null);
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

  /// deserialize a row from database
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
    // the key will be present only with join queries
    // in a simple select this data is not present
    if (map.containsKey("manufacturer")) {
      car.manufacturer =
          Manufacturer().fromDb(map["manufacturer"] as Map<String, dynamic>);
    }
    return car;
  }

  /// Create a static join method for convenience

  static Future<List<Car>> selectRelated({String where, int limit}) async {
    final cars = List<Car>.from(
        await Car().sqlJoin(where: where, limit: limit, verbose: true));
    return cars;
  }
}
