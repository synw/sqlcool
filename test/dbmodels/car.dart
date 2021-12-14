import 'package:sqlcool2/sqlcool2.dart';

import 'conf.dart' as conf;
import 'manufacturer.dart';
import 'schema.dart';

class Car with DbModel {
  Car({this.id, this.name, this.price, this.manufacturer});

  final String? name;
  double? price;
  Manufacturer? manufacturer;

  /// [DbModel] required overrides

  @override
  int? id;

  @override
  Db get db => conf.db;

  @override
  DbTable get table => carTable;

  @override
  Map<String, dynamic> toDb() {
    final row = <String, dynamic>{
      "name": name,
      "price": price,
    };
    if (manufacturer != null) {
      row["manufacturer"] = manufacturer!.id;
    }
    return row;
  }

  @override
  Car fromDb(Map<String, dynamic> map) {
    final car = Car(
      id: map["id"] as int?,
      name: map["name"].toString(),
      price: map["price"] as double?,
    );
    if (map.containsKey("manufacturer")) {
      car.manufacturer =
          Manufacturer().fromDb(map["manufacturer"] as Map<String, dynamic>);
    }
    return car;
  }

  static Future<List<Car>> select({String? where, int? limit}) async {
    final cars = List<Car>.from(
        await Car().sqlSelect(where: where, limit: limit, verbose: true));
    return cars;
  }

  static Future<List<Car>> selectRelated({String? where, int? limit}) async {
    final cars = List<Car>.from(
        await Car().sqlJoin(where: where, limit: limit, verbose: true));
    return cars;
  }

  @override
  String toString() {
    return "$id: $name / $price";
  }
}
