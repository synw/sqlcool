import 'package:flutter/foundation.dart';
import 'models.dart';

/// The database schema representation
class DbSchema {
  /// Provide a set of [DbTable]
  DbSchema([this.tables]) {
    tables ??= Set();
  }

  /// The tables in the database
  Set<DbTable> tables;

  /// Get a [DbTable] in the schema from it's name
  DbTable table(String name) {
    DbTable t;
    for (DbTable dbt in tables) {
      if (dbt.name == name) t = dbt;
    }
    return t;
  }

  /// Check if a [DbTable] is present in the schema from it's name
  bool hasTable(String name) {
    for (DbTable dbt in tables) {
      if (dbt.name == name) return true;
    }
    return false;
  }
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

  /// The columns info
  List<DatabaseColumn> get columns => _columnsData;

  /// The columns info
  @deprecated
  List<DatabaseColumn> get schema => _columnsData;

  /// Get the list of queries to perform for database initialization
  List<String> get queries => _getQueries();

  /// Add an index to a column
  void index(String column) {
    String q = "CREATE INDEX idx_$column ON $name ($column)";
    _queries.add(q);
  }

  /// Add a unique constraint for combined values from two columns
  void uniqueTogether(String column1, String column2) {
    String q = "UNIQUE($column1, $column2)";
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
    q += ",\n";
    q += "  FOREIGN KEY ($name)\n";
    reference ??= name;
    q += "  REFERENCES $reference(id)\n";
    q += "  ON DELETE ";
    switch (onDelete) {
      case OnDelete.cascade:
        q += "CASCADE";
        break;
      case OnDelete.setNull:
        q += "SET NULL";
        break;
      case OnDelete.setDefault:
        q += "SET DEFAULT";
        break;
      default:
        q += "RESTRICT";
    }
    _columns.add(q);
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
    if (maxLength != null) q += "($maxLength)";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT $defaultValue";
    if (check != null) q += " CHECK($check)";
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
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT $defaultValue";
    if (check != null) q += " CHECK($check)";
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
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT $defaultValue";
    if (check != null) q += " CHECK($check)";
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
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT $defaultValue";
    if (check != null) q += " CHECK($check)";
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

  /// Print the queries to perform for database initialization
  void printQueries() {
    queries.forEach((q) {
      print("----------");
      print(q);
    });
  }

  @override
  String toString() {
    String q = "CREATE TABLE $name (\n";
    q += _columns.join(",\n");
    q += "\n)";
    return q;
  }

  List<String> _getQueries() {
    var qs = <String>[this.toString()]..addAll(_queries);
    return qs;
  }
}

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
