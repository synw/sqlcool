import 'package:sqlcool/sqlcool.dart';
import '../conf.dart';

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
}
