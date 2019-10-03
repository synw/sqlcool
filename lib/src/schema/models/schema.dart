import 'table.dart';

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
    for (final table in tables) {
      if (table.name == name) {
        t = table;
        break;
      }
    }
    return t;
  }

  /// Check if a [DbTable] is present in the schema from it's name
  bool hasTable(String name) {
    for (final table in tables) {
      if (table.name == name) {
        return true;
      }
    }
    return false;
  }

  /// print a description of the schema
  void describe() {
    for (final table in tables) {
      table.describe(spacer: " ");
    }
  }
}
