import 'package:sqlcool2/sqlcool2.dart';
import 'conf.dart' as conf;
import 'schema.dart';

class Manufacturer with DbModel {
  Manufacturer({this.id, this.name});

  final String? name;

  /// [DbModel] required overrides

  @override
  int? id;

  @override
  Db get db => conf.db;

  @override
  DbTable get table => manufacturerTable;

  @override
  Map<String, dynamic> toDb() => <String, dynamic>{"name": name};

  @override
  Manufacturer fromDb(Map<String, dynamic> map) {
    return Manufacturer(name: map["name"].toString());
  }
}
