import 'package:flutter/foundation.dart';
import 'package:sqlcool/sqlcool.dart';
import 'conf.dart';

class DataModel extends DbModel {
  DataModel(
      {this.id, this.stringVal, this.intVal, this.doubleVal, this.boolVal});

  /// define my class properties

  final String stringVal;
  final int intVal;
  final double doubleVal;
  final bool boolVal;

  /// we need and empty constructor
  DataModel.empty()
      : stringVal = null,
        intVal = null,
        doubleVal = null,
        boolVal = null;

  /// [DbModel] required overrides

  @override
  int id;

  @override
  DbModelTable get dbTable => dataModelTable;

  @override
  Map<String, dynamic> toDb() => <String, dynamic>{
        "string_val": stringVal,
        "int_val": intVal,
        "double_val": doubleVal,
        "bool_val": boolVal
      };

  @override
  DataModel fromDb(Map<String, dynamic> map) {
    return DataModel(
        id: map["id"] as int,
        stringVal: map["string_val"].toString(),
        intVal: map["int_val"] as int,
        doubleVal: map["double_val"] as double,
        boolVal: (map["bool_val"].toString() == "true"));
  }

  /// The table schema generator, as a static method for convenience
  /// This is used to configure the model table

  static DbModelTable tableSchema({@required Db db}) {
    return DbModelTable(
        db: db,
        table: DbTable("data_model")
          ..varchar("string_val")
          ..integer("int_val")
          ..real("double_val")
          ..boolean("bool_val", defaultValue: true));
  }

  /// A custom method that queries the database
  Future<List<DataModel>> selectAll() async =>
      List<DataModel>.from(await sqlSelect());

  /// A custom method that queries the database
  Future<List<DataModel>> selectWhere(String where) async =>
      List<DataModel>.from(await sqlSelect(where: where));
}
