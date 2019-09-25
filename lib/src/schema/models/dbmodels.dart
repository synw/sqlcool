import 'table.dart';
import '../../database.dart';

/// A table representing a model
class DbModelTable {
  /// Provide a [Db] and a [DbTable]
  DbModelTable({this.db, this.table});

  /// The [Db] to use
  Db db;

  /// The [DbTable] database schema definition
  DbTable table;

  bool _dbIsInitialized = false;

  /// Is this initialized
  bool get isInitialized => _dbIsInitialized;

  /// Initialize the model table
  ///
  /// This has to be done before running queries on the model
  Future<void> init() async {
    assert(
        db.isReady,
        "The database is not ready. Make sure to initialize it " +
            "with the db.init() method");
    assert(table != null,
        "The table schema is null: please override dbSchema() in your model");
    // add the table if it does not exist
    await db
        .addTable(table)
        .catchError((dynamic e) => throw ("Can not initialize model table $e"));
    _dbIsInitialized = true;
  }
}

/// The database model class to extend
class DbModel {
  /// Default consructor
  DbModel();

  /// The [DbModelTable] to use
  ///
  /// **Important** : this must be set in all the inherited constructors
  DbModelTable modelTable;

  /// The database row serializer for the model
  ///
  /// **Important** : it must be overrided
  Map<String, dynamic> toDb() => <String, dynamic>{};

  /// The database row deserializer for the model
  ///
  /// **Important** : it must be overrided
  DbModel fromDb(Map<String, dynamic> map) => null;

  /// Select rows in the database table
  Future<List<dynamic>> select(
      {String columns = "*",
      String where,
      String orderBy,
      int limit,
      int offset,
      String groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    final res = await modelTable.db.select(
        table: modelTable.table.name,
        columns: columns,
        where: where,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
        groupBy: groupBy,
        verbose: verbose);
    final endRes = <dynamic>[];
    for (final row in res) {
      endRes.add(fromDb(row));
    }
    return endRes;
  }

  /// Upsert a row in the database table
  Future<void> upsert() async {
    _checkDbIsReady();
    final row = Map<String, String>.from(this.toDb());
    await modelTable.db
        .upsert(table: modelTable.table.name, row: row)
        .catchError((dynamic e) => throw ("Can not upsert to database $e"));
  }

  void _checkDbIsReady() {
    assert(modelTable != null);
    assert(modelTable.db != null);
    assert(
        modelTable.isInitialized,
        "Please intialize your model table schema " +
            "by running myModelSchema.init(db)");
  }
}
