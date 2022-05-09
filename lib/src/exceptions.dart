/// An exception for when the database is not ready
class DatabaseNotReady implements Exception {
  /// A message can be passed or the default message will be used
  DatabaseNotReady([this.message]) {
    message ??= _msg;
  }

  /// The error message
  String? message;

  final String _msg =
      "The Sqlcool database is not ready. This happens when a query is "
      "fired and the database has not finished initializing.";
}

/// An exception for an error on the onDelete constraint in a foreigh key
/// for a table schema
class OnDeleteConstraintUnknown implements Exception {
  /// Provide a message
  OnDeleteConstraintUnknown(this.message);

  /// The error message
  final String message;
}

/// An exception for reading or writing a database asset
class DatabaseAssetProblem implements Exception {
  /// Provide a message
  DatabaseAssetProblem(this.message);

  /// The error message
  final String message;
}

/// An exception for a read query
class ReadQueryException implements Exception {
  /// Provide a message
  ReadQueryException(this.message);

  /// The error message
  final String message;
}

/// An exception for a write query
class WriteQueryException implements Exception {
  /// Provide a message
  WriteQueryException(this.message);

  /// The error message
  final String message;
}

/// An exception for a raw query
class RawQueryException implements Exception {
  /// Provide a message
  RawQueryException(this.message);

  /// The error message
  final String message;
}
