import 'package:flutter/foundation.dart';

enum DatabaseChange { insert, update, delete }

class DatabaseChangeEvent {
  DatabaseChangeEvent(
      {@required this.type,
      @required this.value,
      @required this.query,
      @required this.executionTime});

  DatabaseChange type;
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
