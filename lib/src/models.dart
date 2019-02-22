import 'package:flutter/foundation.dart';

enum DatabaseChangeType { insert, update, delete }

class DatabaseChange {
  DatabaseChange(
      {@required this.type,
      @required this.value,
      @required this.query,
      @required this.executionTime});

  DatabaseChangeType type;
  int value;
  String query;
  num executionTime;

  @override
  String toString() {
    String s = "";
    if (value > 1) {
      s = "s";
    }
    String msg = "";
    if (type == DatabaseChangeType.delete) {
      msg += "$value item$s deleted";
    } else if (type == DatabaseChangeType.update) {
      msg += "$value item$s updated";
    } else if (type == DatabaseChangeType.insert) {
      msg += "$value item$s inserted";
    }
    msg += "\n$type : $value";
    msg += "\n$query in $executionTime ms";
    return msg;
  }
}
