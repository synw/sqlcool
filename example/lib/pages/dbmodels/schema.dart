import 'package:sqlcool/sqlcool.dart';

final carTable = DbTable("car")
  ..varchar("name")
  ..integer("max_speed")
  ..real("price")
  ..integer("year")
  ..boolean("is_4wd", defaultValue: false)
  ..foreignKey("manufacturer", onDelete: OnDelete.cascade);

final manufacturerTable = DbTable("manufacturer")..varchar("name");
