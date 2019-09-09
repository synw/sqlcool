import 'package:flutter/foundation.dart';

/// The type of a database column
enum DatabaseColumnType {
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
class DatabaseColumn {
  /// Provide a name and a type
  const DatabaseColumn(
      {@required this.name,
      @required this.type,
      this.unique = false,
      this.nullable = false,
      this.check,
      this.defaultValue});

  /// The column name
  final String name;

  /// The data type of the column
  final DatabaseColumnType type;

  /// Is the column unique
  final bool unique;

  /// Is the column nullable
  final bool nullable;

  /// The column-s default value
  final String defaultValue;

  /// A check constraint
  final String check;

  /// convert a column type to a string
  String typeToString() {
    String res;
    switch (type) {
      case DatabaseColumnType.varchar:
        res = "varchar";
        break;
      case DatabaseColumnType.integer:
        res = "integer";
        break;
      case DatabaseColumnType.real:
        res = "real";
        break;
      case DatabaseColumnType.boolean:
        res = "boolean";
        break;
      case DatabaseColumnType.text:
        res = "text";
        break;
      case DatabaseColumnType.timestamp:
        res = "timestamp";
        break;
      case DatabaseColumnType.blob:
        res = "blob";
        break;
    }
    return res;
  }
}
