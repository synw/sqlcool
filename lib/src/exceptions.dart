class DatabaseNotReady implements Exception {
  DatabaseNotReady([this.message]) {
    message = message ?? _msg;
  }

  String message;
  final String _msg =
      "The Sqlcool database is not ready. This happens when a query is " +
          "fired and the database has not finished initializing.";
}
