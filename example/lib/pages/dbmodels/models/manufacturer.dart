import 'package:sqlcool/sqlcool.dart';
import '../../../conf.dart' as conf;
import '../schema.dart';

class Manufacturer with DbModel {
  Manufacturer({this.id, this.name});

  final String name;

  /// [DbModel] required overrides

  @override
  int id;

  @override
  Db get db => conf.db;

  @override
  DbTable get table => manufacturerTable;

  @override

  /// we do not set [id] and let the database create it
  /// and manage it's primary keys automatically
  Map<String, dynamic> toDb() => <String, dynamic>{"name": name};

  @override
  Manufacturer fromDb(Map<String, dynamic> map) {
    return Manufacturer(id: map["id"] as int, name: map["name"].toString());
  }
}
