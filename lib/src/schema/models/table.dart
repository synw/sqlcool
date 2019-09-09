import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'column.dart';

/// types of on delete actions for foreign keys
enum OnDelete {
  /// delete the children when the foreign key is deleted
  cascade,

  /// protect the children when the foreign key is deleted
  restrict,

  /// set the children to null when the foreign key is deleted
  setNull,

  /// set the children to the default value when the foreign key is deleted
  setDefault
}

/// The class used to create tables
class DbTable {
  /// Default constructor
  DbTable(this.name) : assert(name != null);

  /// Name of the table: no spaces
  final String name;

  final List<String> _columns = <String>["id INTEGER PRIMARY KEY"];
  final List<String> _queries = <String>[];
  final List<DatabaseColumn> _columnsData = <DatabaseColumn>[];
  final List<String> _fkConstraints = <String>[];

  /// The columns info
  List<DatabaseColumn> get columns => _columnsData;

  /// The columns info
  @deprecated
  List<DatabaseColumn> get schema => _columnsData;

  /// Get the list of queries to perform for database initialization
  List<String> get queries => _getQueries();

  /// Get the table constraints
  List<String> get constraints => _fkConstraints;

  /// Add an index to a column
  void index(String column) {
    final String q = "CREATE INDEX idx_${name}_$column ON $name($column)";
    _queries.add(q);
  }

  /// Add a unique constraint for combined values from two columns
  void uniqueTogether(String column1, String column2) {
    final String q = "UNIQUE($column1, $column2)";
    _queries.add(q);
  }

  /// Add a foreign key to a column
  void foreignKey(String name,
      {String reference,
      bool nullable = false,
      bool unique = false,
      String defaultValue,
      OnDelete onDelete = OnDelete.restrict}) {
    String q = "$name INTEGER";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT $defaultValue";
    //q += ",\n";
    String fk;
    fk = "  FOREIGN KEY ($name)\n";
    reference ??= name;
    fk += "  REFERENCES $reference(id)\n";
    fk += "  ON DELETE ";
    switch (onDelete) {
      case OnDelete.cascade:
        fk += "CASCADE";
        break;
      case OnDelete.setNull:
        fk += "SET NULL";
        break;
      case OnDelete.setDefault:
        fk += "SET DEFAULT";
        break;
      default:
        fk += "RESTRICT";
    }
    _columns.add(q);
    _fkConstraints.add(fk);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: defaultValue,
        type: DatabaseColumnType.integer));
  }

  /// Add a varchar column
  void varchar(String name,
      {int maxLength,
      bool nullable = false,
      bool unique = false,
      String defaultValue,
      String check}) {
    String q = "$name VARCHAR";
    if (maxLength != null) {
      q += "($maxLength)";
    }
    if (unique) {
      q += " UNIQUE";
    }
    if (!nullable) {
      q += " NOT NULL";
    }
    if (defaultValue != null) {
      q += " DEFAULT $defaultValue";
    }
    if (check != null) {
      q += " CHECK($check)";
    }
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: defaultValue,
        check: check,
        type: DatabaseColumnType.varchar));
  }

  /// Add a text column
  void text(String name,
      {bool nullable = false,
      bool unique = false,
      String defaultValue,
      String check}) {
    String q = "$name TEXT";
    if (unique) {
      q += " UNIQUE";
    }
    if (!nullable) {
      q += " NOT NULL";
    }
    if (defaultValue != null) {
      q += " DEFAULT $defaultValue";
    }
    if (check != null) {
      q += " CHECK($check)";
    }
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: defaultValue,
        check: check,
        type: DatabaseColumnType.text));
  }

  /// Add a float column
  void real(String name,
      {bool nullable = false,
      bool unique = false,
      double defaultValue,
      String check}) {
    String q = "$name REAL";
    if (unique) {
      q += " UNIQUE";
    }
    if (!nullable) {
      q += " NOT NULL";
    }
    if (defaultValue != null) {
      q += " DEFAULT $defaultValue";
    }
    if (check != null) {
      q += " CHECK($check)";
    }
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: "$defaultValue",
        check: check,
        type: DatabaseColumnType.real));
  }

  /// Add an integer column
  void integer(
    String name, {
    bool nullable = false,
    bool unique = false,
    int defaultValue,
    String check,
  }) {
    String q = "$name INTEGER";
    if (unique) {
      q += " UNIQUE";
    }
    if (!nullable) {
      q += " NOT NULL";
    }
    if (defaultValue != null) {
      q += " DEFAULT $defaultValue";
    }
    if (check != null) {
      q += " CHECK($check)";
    }
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: "$defaultValue",
        check: check,
        type: DatabaseColumnType.integer));
  }

  /// Add a float column
  void boolean(String name, {@required bool defaultValue}) {
    String q = "$name REAL";
    q += " DEFAULT $defaultValue";
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        defaultValue: "$defaultValue",
        type: DatabaseColumnType.boolean));
  }

  /// Add a blob column
  void blob(
    String name, {
    bool nullable = false,
    bool unique = false,
    Uint8List defaultValue,
    String check,
  }) {
    String q = "$name BLOB";
    if (unique) {
      q += " UNIQUE";
    }
    if (!nullable) {
      q += " NOT NULL";
    }
    if (defaultValue != null) {
      q += " DEFAULT $defaultValue";
    }
    if (check != null) {
      q += " CHECK($check)";
    }
    _columns.add(q);
    _columnsData.add(DatabaseColumn(
        name: name,
        unique: unique,
        nullable: nullable,
        defaultValue: "$defaultValue",
        check: check,
        type: DatabaseColumnType.blob));
  }

  /// Add an automatic timestamp
  void timestamp([String name = "timestamp"]) {
    final String q =
        "$name INTEGER DEFAULT (cast(strftime('%s','now') as int)) NOT NULL";
    _columns.add(q);
    _columnsData
        .add(DatabaseColumn(name: name, type: DatabaseColumnType.timestamp));
  }

  /// Print the queries to perform for database initialization
  void printQueries() {
    queries.forEach((q) {
      print("----------");
      print(q);
    });
  }

  @override
  String toString() {
    String q = "CREATE TABLE IF NOT EXISTS $name (\n";
    q += _columns.join(",\n");
    if (_fkConstraints.isNotEmpty) {
      q += ",\n";
      q += _fkConstraints.join(",\n");
    }
    q += "\n)";
    return q;
  }

  List<String> _getQueries() {
    final qs = <String>[this.toString()]..addAll(_queries);
    return qs;
  }
}
