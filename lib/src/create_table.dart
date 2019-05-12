/// The class used to create tables
class DbTable {
  /// Default constructor
  DbTable(this.name) : assert(name != null);

  /// Name of the table: no spaces
  final String name;

  final List<String> _columns = <String>["id INTEGER PRIMARY KEY"];
  final List<String> _queries = <String>[];

  /// Get the database schema string
  String get schema => _schema();

  /// Get the list of queries to perform for database initialization
  List<String> get queries => _getQueries();

  /// Add an index to a column
  void index(String column) {
    String q = "CREATE INDEX idx_$column ON $name ($column)";
    _queries.add(q);
  }

  /// Add a foreign key to a column
  void foreignKey(String name,
      {String reference,
      bool nullable = false,
      bool unique = false,
      OnDelete onDelete = OnDelete.restrict}) {
    String q = "${name}_id INTEGER";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    q += ",\n";
    q += "CONSTRAINT $name\n";
    q += "  FOREIGN KEY (${name}_id)\n";
    reference ??= name;
    q += "  REFERENCES $reference(id)\n";
    q += "  ON DELETE ";
    switch (onDelete) {
      case OnDelete.cascade:
        q += "CASCADE";
        break;
      case OnDelete.setNull:
        q += "SET NULL";
        break;
      case OnDelete.setDefault:
        q += "SET DEFAULT";
        break;
      default:
        q += "RESTRICT";
    }
    _columns.add(q);
  }

  /// Add a varchar column
  void varchar(String name,
      {int maxLength,
      bool nullable = false,
      bool unique = false,
      String defaultValue}) {
    String q = "$name VARCHAR";
    if (maxLength != null) q += "($maxLength)";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT ($defaultValue)";
    _columns.add(q);
  }

  /// Add a text column
  void text(String name,
      {bool nullable = false, bool unique = false, String defaultValue}) {
    String q = "$name TEXT";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT ($defaultValue)";
    _columns.add(q);
  }

  /// Add a float column
  void real(String name,
      {bool nullable = false, bool unique = false, String defaultValue}) {
    String q = "$name REAL";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT ($defaultValue)";
    _columns.add(q);
  }

  /// Add an integer column
  void integer(String name,
      {bool nullable = false, bool unique = false, String defaultValue}) {
    String q = "$name INTEGER";
    if (unique) q += " UNIQUE";
    if (!nullable) q += " NOT NULL";
    if (defaultValue != null) q += " DEFAULT ($defaultValue)";
    _columns.add(q);
  }

  /// Print the queries to perform for database initialization
  void printQueries() {
    queries.forEach((q) {
      print("----------");
      print(q);
    });
  }

  String _schema() {
    String q = "CREATE TABLE $name (\n";
    q += _columns.join(",\n");
    q += "\n)";
    return q;
  }

  List<String> _getQueries() {
    var qs = <String>[_schema()]..addAll(_queries);
    return qs;
  }
}

/// types of on delete actions for foreign keys
enum OnDelete {
  /// delete the children when the foreign key is deleted
  cascade,

  /// protect the children when the foreign key is deleted
  restrict,

  /// set the children to null when the foreign key is deleted
  setNull,

  /// set the children to the default value when the foreign key is deleted
  setDefault
}
