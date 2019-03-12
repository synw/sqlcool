/// An exception for when the database is not ready
class DatabaseNotReady implements Exception {
  /// A message can be passed or the default message will be used
  DatabaseNotReady([this.message]) {
    message ??= _msg;
  }

  /// The error message
  String message;

  final String _msg =
      "The Sqlcool database is not ready. This happens when a query is " +
          "fired and the database has not finished initializing.";
}
