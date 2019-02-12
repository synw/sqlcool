class ChangeFeedItem {
  ChangeFeedItem(this.changeType, this.value, this.query);

  String changeType;
  int value;
  String query;

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
    } else if (changeType == "create") {
      msg += "$value item$s created";
    }
    msg += "\n$changeType : $value";
    msg += "\n$query";
    return msg;
  }
}
