import 'models/table.dart';
import 'models/column.dart';

/// internal table representation
final schemaTable = DbTable("sqlcool_schema_table")..varchar("name");

/// internal table column representation
final schemaColumn = DbTable("sqlcool_schema_column")
  ..varchar("name")
  ..varchar("type",
      check: 'type="varchar" OR type="integer" OR type="real" ' +
          'OR type="text" OR type="boolean" OR type="blob" OR type="timestamp"')
  ..boolean("is_unique", defaultValue: false)
  ..boolean("is_nullable", defaultValue: true)
  ..varchar("default_value_string", nullable: true)
  ..varchar("check_string", nullable: true)
  ..boolean("is_foreign_key", defaultValue: false)
  ..varchar("reference", nullable: true)
  ..varchar("on_delete", nullable: true)
  ..foreignKey("table_id",
      reference: "sqlcool_shema_table", onDelete: OnDelete.cascade);

/// convert a column string type to a column type
DatabaseColumnType columnStringToType(String typeString) {
  DatabaseColumnType type;
  switch (typeString) {
    case "varchar":
      type = DatabaseColumnType.varchar;
      break;
    case "integer":
      type = DatabaseColumnType.integer;
      break;
    case "real":
      type = DatabaseColumnType.real;
      break;
    case "boolean":
      type = DatabaseColumnType.boolean;
      break;
    case "text":
      type = DatabaseColumnType.text;
      break;
    case "timestamp":
      type = DatabaseColumnType.timestamp;
      break;
    case "blob":
      type = DatabaseColumnType.blob;
      break;
    default:
      throw ("Unknown column type $typeString");
  }
  return type;
}
