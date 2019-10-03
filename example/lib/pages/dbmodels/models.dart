import 'package:flutter/foundation.dart';
import 'package:sqlcool/sqlcool.dart';
import 'conf.dart';

class Car with DbModel {
  Car(
      {this.id,
      this.name,
      this.maxSpeed,
      this.price,
      this.year,
      this.is4wd,
      this.manufacturer});

  /// define my class properties

  final String name;
  final int maxSpeed;
  final double price;
  final DateTime year;
  final bool is4wd;
  Manufacturer manufacturer;

  /// [DbModel] required overrides

  @override
  int id;

  @override
  DbModelTable get dbTable => carModelTable;

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
    //print("Serialized car data to database: $row");
    return row;
  }

  @override
  Car fromDb(Map<String, dynamic> map) {
    //print("Deserializing car data from database: $map");
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

  /// The table schema generator, as a static method for convenience
  /// This is used to configure the model table

  static DbModelTable modelSchema({@required Db db}) {
    return DbModelTable(
        db: db,
        table: DbTable("car")
          ..varchar("name")
          ..integer("max_speed")
          ..real("price")
          ..integer("year")
          ..boolean("is_4wd", defaultValue: false)
          ..foreignKey("manufacturer", onDelete: OnDelete.cascade));
  }

  /// Create a static select method for convenience

  static Future<List<Car>> select({String where, int limit}) async {
    final cars = List<Car>.from(
        await Car().sqlJoin(where: where, limit: limit, verbose: true));
    return cars;
  }
}

class Manufacturer with DbModel {
  Manufacturer({this.id, this.name});

  final String name;

  /// [DbModel] required overrides

  @override
  int id;

  @override
  DbModelTable get dbTable => manufacturerModelTable;

  @override
  Map<String, dynamic> toDb() => <String, dynamic>{"name": name};

  @override
  Manufacturer fromDb(Map<String, dynamic> map) {
    return Manufacturer(name: map["name"].toString());
  }

  static DbModelTable modelSchema({@required Db db}) {
    return DbModelTable(
        db: db, table: DbTable("manufacturer")..varchar("name"));
  }
}
