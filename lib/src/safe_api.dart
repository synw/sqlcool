import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';
import 'models.dart';
import 'schema/models/row.dart';
import 'schema/models/schema.dart';
import 'schema/models/table.dart';

/// A Sqlite database
class SqlDb {
  /// Base constructor
  SqlDb() {
    _db = Db(sqfliteDatabase: sqfliteDatabase);
  }

  /// An Sqlite database:
  ///
  /// Use this parameter if you want to work with an existing
  /// Sqflite database
  Database sqfliteDatabase;

  Db _db;

  /// A stream of [DatabaseChangeEvent] with all the changes
  /// that occur in the database
  Stream<DatabaseChangeEvent> get changefeed => _db.changefeed;

  /// This Sqflite [Database]
  Database get database => _db.database;

  /// This Sqlite file
  File get file => _db.file;

  /// Check the existence of a schema
  bool get hasSchema => _db.hasSchema;

  /// This database state
  bool get isReady => _db.isReady;

  /// The on ready callback: fired when the database
  /// is ready to operate
  Future<void> get onReady => _db.onReady;

  /// This database schema
  DbSchema get schema => _db.schema;

  /// Initialize the database
  ///
  /// The database can be initialized either from an asset file
  /// with the [fromAsset] parameter or from a [schema] or from
  /// create table and other [queries]. A [schema] must be provided.
  Future<void> init(
      {@required String path,
      @required List<DbTable> schema,
      bool absolutePath = false,
      List<String> queries = const <String>[],
      bool verbose = false,
      String fromAsset,
      bool debug = false}) async {
    assert(schema != null);
    await _db.init(
        path: path,
        absolutePath: absolutePath,
        queries: queries,
        schema: schema,
        verbose: verbose,
        fromAsset: fromAsset,
        debug: debug);
  }

  /// Insert a row in a table
  ///
  /// [table] the table to insert into
  ///
  /// Returns a future with the last inserted id
  Future<int> insert(
      {@required String table,
      @required DbRow row,
      bool verbose = false}) async {
    int res;
    try {
      res = await _db.insert(
          table: table, row: row.toStringsMap(), verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return res;
  }

  /// Insert a row in a table with conflict algorithm
  ///
  /// [table] the table to insert into. [row] is a map of the data
  /// to insert
  ///
  /// Returns a future with the last inserted id
  Future<int> insertManageConflict(
      {@required String table,
      @required ConflictAlgorithm conflictAlgorithm,
      @required DbRow row,
      bool verbose = false}) async {
    int res;
    try {
      res = await _db.insertManageConflict(
          table: table,
          conflictAlgorithm: conflictAlgorithm,
          row: row.toMap(),
          verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return res;
  }

  /// A select query
  Future<List<DbRow>> select(
      {@required String table,
      String columns = "*",
      String where,
      String orderBy,
      int limit,
      int offset,
      String groupBy,
      bool verbose = false}) async {
    List<Map<String, dynamic>> data;
    try {
      data = await _db.select(
          table: table,
          columns: columns,
          where: where,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
          groupBy: groupBy,
          verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return _rowsFromRawData(table, data);
  }

  /// Update some datapoints in the database
  Future<int> update(
      {@required String table,
      @required DbRow row,
      @required String where,
      bool verbose = false}) async {
    int res;
    try {
      res = await _db.update(
          table: table,
          row: row.toStringsMap(),
          where: where,
          verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return res;
  }

  /// Insert a row if it does not exist or update it
  ///
  /// It is highly recommended to use an unique index for the table
  /// to upsert into
  Future<void> upsert(
      {@required String table,
      @required DbRow row,
      //@required List<String> columns,
      List<String> preserveColumns = const [],
      String indexColumn,
      bool verbose = false}) async {
    try {
      await _db.upsert(table: table, row: row.toStringsMap(), verbose: verbose);
    } catch (e) {
      rethrow;
    }
  }

  /// Insert rows in a table
  Future<List<dynamic>> batchInsert(
      {@required String table,
      @required List<DbRow> rows,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.rollback,
      bool verbose = false}) async {
    final data = <Map<String, String>>[];
    rows.forEach((row) => data.add(row.toStringsMap()));
    var res = <dynamic>[];
    try {
      res = await _db.batchInsert(table: table, rows: data);
    } catch (e) {
      rethrow;
    }
    return res;
  }

  /// A select query with a join
  Future<List<DbRow>> join(
      {@required String table,
      @required String joinTable,
      @required String joinOn,
      String columns = "*",
      int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool verbose = false}) async {
    List<Map<String, dynamic>> data;
    try {
      data = await _db.join(
          table: table,
          joinTable: joinTable,
          joinOn: joinOn,
          columns: columns,
          offset: offset,
          limit: limit,
          orderBy: orderBy,
          where: where,
          groupBy: groupBy,
          verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return _rowsFromRawData(table, data);
  }

  /// A select query with a join on multiple tables
  Future<List<DbRow>> mJoin(
      {@required String table,
      @required List<String> joinsTables,
      @required List<String> joinsOn,
      String columns = "*",
      int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool verbose = false}) async {
    List<Map<String, dynamic>> data;
    try {
      data = await _db.mJoin(
          table: table,
          joinsTables: joinsTables,
          joinsOn: joinsOn,
          columns: columns,
          offset: offset,
          limit: limit,
          orderBy: orderBy,
          where: where,
          groupBy: groupBy,
          verbose: verbose);
    } catch (e) {
      rethrow;
    }
    return _rowsFromRawData(table, data);
  }

  /// Delete some datapoints from the database
  Future<int> delete(
          {@required String table,
          @required String where,
          bool verbose = false}) async =>
      _db.delete(table: table, where: where, verbose: verbose);

  /// Execute a query
  Future<List<Map<String, dynamic>>> query(String q,
          {bool verbose = false}) async =>
      _db.query(q, verbose: verbose);

  /// count rows in a table
  Future<int> count(
          {@required String table,
          String where,
          String columns = "id",
          bool verbose = false}) async =>
      _db.count(table: table, where: where, columns: columns, verbose: verbose);

  List<DbRow> _rowsFromRawData(String table, List<Map<String, dynamic>> data) {
    final rows = <DbRow>[];
    DbTable t;
    try {
      t = schema.table(table);
    } catch (e) {
      rethrow;
    }
    data.forEach((r) => rows.add(DbRow.fromMap(t, r)));
    return rows;
  }

  /// Check if a value exists in the table
  Future<bool> exists(
          {@required String table,
          @required String where,
          bool verbose = false}) async =>
      _db.exists(table: table, where: where, verbose: verbose);

  /// Dispose when finished using
  void dispose() => _db.dispose();
}
