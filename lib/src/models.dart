import 'package:flutter/foundation.dart';

/// Types of database changes
enum DatabaseChange { insert, update, delete }

/// A database change event. Used by the changefeed
class DatabaseChangeEvent {
  /// Default database change event
  DatabaseChangeEvent(
      {@required this.type,
      @required this.value,
      @required this.query,
      @required this.executionTime});

  /// Type of the change
  DatabaseChange type;

  /// Change value: number of items affected
  int value;

  /// The query that made the changes
  String query;

  /// The query execution time
  num executionTime;

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
