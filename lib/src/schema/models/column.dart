import 'package:flutter/foundation.dart';
import 'package:sqlcool/sqlcool.dart';

/// The type of a database column
enum DbColumnType {
  /// A varchar column
  varchar,

  /// An integer column
  integer,

  /// A double column
  real,

  /// A text column
  text,

  /// A boolean colum
  boolean,

  /// A blob value
  blob,

  /// An automatic timestamp
  timestamp
}

/// A database column representation
class DbColumn {
  /// Provide a name and a type
  const DbColumn(
      {@required this.name,
      @required this.type,
      this.unique = false,
      this.nullable = false,
      this.check,
      this.defaultValue,
      this.isForeignKey = false,
      this.reference,
      this.onDelete});

  /// The column name
  final String name;

  /// The data type of the column
  final DbColumnType type;

  /// Is the column unique
  final bool unique;

  /// Is the column nullable
  final bool nullable;

  /// The column-s default value
  final String defaultValue;

  /// A check constraint
  final String check;

  /// If the column is a foreign key
  final bool isForeignKey;

  /// A foreign key table name reference
  final String reference;

  /// The on delete constraint on a foreign key
  final OnDelete onDelete;

  /// print a description of the schema
  String describe({String spacer = "", bool isPrint = true}) {
    final lines = <String>[
      "${spacer}Column $name:",
      "$spacer - Type: $type",
      "$spacer - Unique: $unique",
      "$spacer - Nullable: $nullable",
      "$spacer - Default value: $defaultValue",
      "$spacer - Is foreign key: $isForeignKey",
      "$spacer - Reference: $reference",
      "$spacer - On delete: $onDelete",
    ];
    var s = "";
    switch (isPrint) {
      case false:
        s = lines.join("\n");
        break;
      default:
        print(lines.join("\n"));
    }
    return s;
  }

  /// convert a column type to a string
  String typeToString() {
    String res;
    switch (type) {
      case DbColumnType.varchar:
        res = "varchar";
        break;
      case DbColumnType.integer:
        res = "integer";
        break;
      case DbColumnType.real:
        res = "real";
        break;
      case DbColumnType.boolean:
        res = "boolean";
        break;
      case DbColumnType.text:
        res = "text";
        break;
      case DbColumnType.timestamp:
        res = "timestamp";
        break;
      case DbColumnType.blob:
        res = "blob";
        break;
    }
    return res;
  }
}

/// Convert a string to an on delete constraint
OnDelete stringToOnDelete(String value) {
  OnDelete res;
  switch (value) {
    case "restrict":
      res = OnDelete.restrict;
      break;
    case "cascade":
      res = OnDelete.cascade;
      break;
    case "set_null":
      res = OnDelete.setNull;
      break;
    case "set_default":
      res = OnDelete.setDefault;
      break;
    default:
      throw ("Unknown on delete constraint $value");
  }
  return res;
}

/// Convert an on delete constraint to a string
String onDeleteToString(OnDelete onDelete) {
  String res;
  switch (onDelete) {
    case OnDelete.cascade:
      res = "cascade";
      break;
    case OnDelete.restrict:
      res = "restrict";
      break;
    case OnDelete.setDefault:
      res = "set_default";
      break;
    case OnDelete.setNull:
      res = "set_null";
      break;
  }
  return res;
}
