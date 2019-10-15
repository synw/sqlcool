import 'package:sqlcool/sqlcool.dart';

final carTable = DbTable("car")
  ..varchar("name")
  ..real("price")
  ..foreignKey("manufacturer", onDelete: OnDelete.cascade);

final manufacturerTable = DbTable("manufacturer")..varchar("name");
