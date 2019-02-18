class DatabaseNotReady implements Exception {
  DatabaseNotReady([this.message]) {
    message = message ?? _msg;
  }
  String message;
  String _msg =
      "The Sqlcool database is not ready. This happens when a query is fired and the database has not finished initializing.";
}
