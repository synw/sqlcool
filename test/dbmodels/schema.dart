import 'package:sqlcool2/sqlcool2.dart';

final DbTable carTable = DbTable("car")
  ..varchar("name")
  ..real("price")
  ..foreignKey("manufacturer", onDelete: OnDelete.cascade);

final DbTable manufacturerTable = DbTable("manufacturer")..varchar("name");
