import 'package:flutter/foundation.dart';
import 'table.dart';
import '../../database.dart';

/// A table representing a model
class DbModelTable {
  /// Provide a [Db] and a [DbTable]
  DbModelTable({@required this.db, @required this.table});

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
  Future<void> init({bool verbose = false}) async {
    assert(
        db.isReady,
        "The database is not ready. Make sure to initialize it " +
            "with the db.init() method");
    assert(table != null,
        "The table schema is null: please override dbSchema() in your model");
    if (verbose) {
      print("Initializing table model ${table.name}");
    }
    // add the table if it does not exist
    await db
        .addTable(table, verbose: verbose)
        .catchError((dynamic e) => throw ("Can not initialize model table $e"));
    _dbIsInitialized = true;
  }
}

/// The database model class to extend
class DbModel {
  /// Default consructor
  DbModel([this.id]);

  /// The [DbModelTable] to use
  ///
  /// **Important** : this must be set in all the inherited constructors
  DbModelTable dbTable;

  /// The database id of the model instance
  ///
  /// **Important** : it must be overriden
  int id;

  /// The database row serializer for the model
  ///
  /// **Important** : it must be overriden
  Map<String, dynamic> toDb() => <String, dynamic>{};

  /// The database row deserializer for the model
  ///
  /// **Important** : it must be overriden
  DbModel fromDb(Map<String, dynamic> map) => null;

  /// Select rows in the database table
  Future<List<dynamic>> sqlSelect(
      {String columns = "*",
      String where,
      String orderBy,
      int limit,
      int offset,
      String groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    final res = await dbTable.db.select(
        table: dbTable.table.name,
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
  Future<void> sqlUpsert({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await dbTable.db
        .upsert(table: dbTable.table.name, row: row, verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not upsert model into database $e"));
  }

  /// Insert a row in the database table
  Future<void> sqlInsert({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await dbTable.db
        .insert(table: dbTable.table.name, row: row, verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not insert model into database $e"));
  }

  /// Delete an instance from the database
  Future<void> sqlDelete({String where, bool verbose = false}) async {
    _checkDbIsReady();
    if (where == null) {
      where = "id=$id";
    }
    await dbTable.db
        .delete(table: dbTable.table.name, where: where, verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not delete model from database $e"));
  }

  Map<String, String> _toStringsMap(Map<String, dynamic> map) {
    final res = <String, String>{};
    map.forEach((String k, dynamic v) => res[k] = "$v");
    return res;
  }

  void _checkDbIsReady() {
    assert(dbTable != null);
    assert(dbTable.db != null);
    assert(
        dbTable.isInitialized,
        "Please intialize your model table schema " +
            "by running myModelSchema.init(db)");
  }
}
