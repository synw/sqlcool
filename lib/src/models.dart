import 'package:flutter/foundation.dart';

class ChangeFeedItem {
  ChangeFeedItem(
      {@required this.changeType,
      @required this.value,
      @required this.query,
      @required this.executionTime});

  String changeType;
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
    if (changeType == "delete") {
      msg += "$value item$s deleted";
    } else if (changeType == "update") {
      msg += "$value item$s updated";
    } else if (changeType == "insert") {
      msg += "$value item$s inserted";
    }
    msg += "\n$changeType : $value";
    msg += "\n$query in $executionTime ms";
    return msg;
  }
}
