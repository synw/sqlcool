import 'package:flutter/foundation.dart';

/// Types of database changes
enum DatabaseChange {
  /// An insert operation in the database
  insert,

  /// An update operation in the database
  update,

  /// A delete operation in the database
  delete,

  /// An upsert operation in the database
  upsert
}

/// A database change event. Used by the changefeed
class DatabaseChangeEvent {
  /// Default database change event
  DatabaseChangeEvent(
      {@required this.type,
      @required this.value,
      @required this.query,
      @required this.table,
      @required this.executionTime});

  /// Type of the change
  final DatabaseChange type;

  /// Change value: number of items affected
  final int value;

  /// The query that made the changes
  final String query;

  /// The query execution time
  final num executionTime;

  /// The table where the changes occur
  final String table;

  /// Human readable format
  @override
  String toString() {
    String s = "";
    if (value > 1) {
      s = "s";
    }
    String msg = "";
    if (type == DatabaseChange.delete) {
      msg += "$value item$s deleted";
    } else if (type == DatabaseChange.update) {
      msg += "$value item$s updated";
    } else if (type == DatabaseChange.insert) {
      msg += "$value item$s inserted";
    }
    msg += "\n$type : $value";
    msg += "\n$query in $executionTime ms";
    return msg;
  }
}
