import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:synchronized/synchronized.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';
import 'exceptions.dart';
import 'schema.dart';

/// A class to handle database operations
class Db {
  /// An empty database. Has to be initialized with [init]
  Db({this.sqfliteDatabase}) {
    if (sqfliteDatabase != null) {
      _db = sqfliteDatabase;
      _dbFile = File(sqfliteDatabase.path);
      _isReady = true;
      _readyCompleter.complete();
    }
  }

  /// An Sqlite database:
  ///
  /// Use this parameter if you want to work with an existing
  /// Sqflite database
  final Database sqfliteDatabase;

  Database _db;

  final _mutex = Lock();
  final Completer<Null> _readyCompleter = Completer<Null>();
  final StreamController<DatabaseChangeEvent> _changeFeedController =
      StreamController<DatabaseChangeEvent>.broadcast();
  File _dbFile;
  bool _isReady = false;
  DbSchema _schema;

  /// The on ready callback: fired when the database
  /// is ready to operate
  Future<Null> get onReady => _readyCompleter.future;

  /// A stream of [DatabaseChangeEvent] with all the changes
  /// that occur in the database
  Stream<DatabaseChangeEvent> get changefeed => _changeFeedController.stream;

  /// This Sqlite file
  File get file => _dbFile;

  /// This Sqflite [Database]
  Database get database => _db;

  /// This database state
  bool get isReady => _isReady;

  /// This database schema
  DbSchema get schema => _schema;

  /// Check the existence of a schema
  bool get hasSchema => (_schema != null);

  /// Dispose the changefeed stream when finished using
  void dispose() {
    _changeFeedController.close();
  }

  /// Initialize the database
  ///
  /// The database can be initialized either from an asset file
  /// with the [fromAsset] parameter or from a [schema] or from
  /// create table and other [queries]. Either a [schema] or [query]
  /// parameter must be provided.
  Future<void> init(
      {@required String path,
      bool absolutePath = false,
      List<String> queries = const <String>[],
      List<DbTable> schema = const <DbTable>[],
      bool verbose = false,
      String fromAsset,
      bool debug = false}) async {
    /// The [path] is where the database file will be stored. It is by
    /// default relative to the documents directory unless [absolutePath]
    /// is true.
    /// [queries] is a list of queries to run at initialization
    /// and [debug] set Sqflite debug mode on.
    ///
    /// Either a [queries] or a [schema] must be provided if the
    /// database is not initialized from an asset
    assert(path != null);
    if (fromAsset == null && queries.isEmpty && schema.isEmpty)
      throw ArgumentError("Either a [queries] or a [schema] must be provided");
    if (debug) Sqflite.setDebugModeOn(true);
    String dbpath = path;
    if (!absolutePath) {
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      dbpath = documentsDirectory.path + "/" + path;
    }
    if (verbose) print("INITIALIZING DATABASE at " + dbpath);
    // copy the database from an asset if necessary
    if (fromAsset != null) {
      final File file = File(dbpath);
      if (!file.existsSync()) {
        if (verbose) print("Copying the database from asset $fromAsset");
        List<int> bytes;
        try {
          // read
          final ByteData data = await rootBundle.load("$fromAsset");
          bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        } catch (e) {
          throw ("Unable to read database from asset: $e");
        }
        try {
          // create the directories path if necessary
          if (!file.parent.existsSync())
            file.parent.createSync(recursive: true);
          // write
          await file.writeAsBytes(bytes);
        } catch (e) {
          throw ("Unable to write database from asset: $e");
        }
      }
    }
    if (this._db == null) {
      await _mutex.synchronized(() async {
        // open
        if (verbose) print("OPENING database");
        this._db = await openDatabase(dbpath, version: 1,
            onCreate: (Database _db, int version) async {
          if (schema != null) {
            final schemaQueries = <String>[];
            schema.forEach(
                (tableSchema) => schemaQueries.addAll(tableSchema.queries));
            schemaQueries.addAll(queries);
            queries = schemaQueries;
          }
          if (queries.isNotEmpty) {
            await _db.transaction((txn) async {
              for (final String q in queries) {
                final Stopwatch timer = Stopwatch()..start();
                await txn.execute(q);
                timer.stop();
                if (verbose) {
                  final String msg = "$q in ${timer.elapsedMilliseconds} ms";
                  print(msg);
                }
              }
            });
          }
        });
      });
    }
    if (schema != null)
      // save the schema in memory
      _schema = DbSchema(schema.toSet());
    if (verbose) print("DATABASE INITIALIZED");
    _dbFile = File(dbpath);
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
    _isReady = true;
  }

  /// Execute a query
  Future<List<Map<String, dynamic>>> query(String q,
      {bool verbose = false}) async {
    /// [q] the query to execute
    try {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      List<Map<String, dynamic>> res;
      await _db.transaction((txn) async {
        res = await txn.rawQuery(q);
      });
      timer.stop();
      if (verbose) {
        final String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return res;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
  }

  /// A select query
  Future<List<Map<String, dynamic>>> select(
      {@required String table,
      String columns = "*",
      String where,
      String orderBy,
      int limit,
      int offset,
      String groupBy,
      bool verbose = false}) async {
    /// [table] the table to select from
    /// [columns] the columns to return
    /// [where] the sql where clause
    /// [orderBy] the sql order_by clause
    /// [limit] the sql limit clause
    /// [offset] the sql offset clause
    /// [verbose] print the query
    /// returns the selected data
    try {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      String q = "SELECT $columns FROM $table";
      if (where != null) q += " WHERE $where";
      if (groupBy != null) q += " GROUP BY $groupBy";
      if (orderBy != null) q += " ORDER BY $orderBy";
      if (limit != null) q += " LIMIT $limit";
      if (offset != null) q += " OFFSET $offset";
      List<Map<String, dynamic>> res;
      await _db.transaction((txn) async {
        res = await txn.rawQuery(q);
      });
      timer.stop();
      if (verbose) {
        final String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return res;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
  }

  /// A select query with a join
  Future<List<Map<String, dynamic>>> join(
      {@required String table,
      @required String joinTable,
      @required String joinOn,
      String columns = "*",
      int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool verbose}) async {
    /// [table] the table to select from
    /// [joinTable] the table to join from
    /// [joinOn] the columns to join
    /// [columns] the columns to return
    /// [where] the sql where clause
    /// [orderBy] the sql order_by clause
    /// [limit] the sql limit clause
    /// [offset] the sql offset clause
    /// [verbose] print the query
    /// returns the selected data
    try {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      String q = "SELECT $columns FROM $table";
      q = "$q INNER JOIN $joinTable ON $joinOn";
      if (where != null) q += " WHERE $where";
      if (groupBy != null) q += " GROUP BY $groupBy";
      if (orderBy != null) q += " ORDER BY $orderBy";
      if (limit != null) q += " LIMIT $limit";
      if (offset != null) q += " OFFSET $offset";
      List<Map<String, dynamic>> res;
      await _db.transaction((txn) async {
        res = await txn.rawQuery(q);
      });
      timer.stop();
      if (verbose) {
        final String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return res;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
  }

  /// Insert a row in a table
  Future<int> insert(
      {@required String table,
      @required Map<String, String> row,
      bool verbose = false}) async {
    /// [table] the table to insert into. [row] is a map of the data
    /// to insert
    ///
    /// Returns a future with the last inserted id
    int id;
    await _mutex.synchronized(() async {
      try {
        if (!_isReady) throw DatabaseNotReady();
        final Stopwatch timer = Stopwatch()..start();
        String fields = "";
        String values = "";
        final int n = row.length;
        int i = 1;
        final List<String> datapoint = [];
        for (final k in row.keys) {
          fields = "$fields$k";
          values = "$values?";
          datapoint.add(row[k]);
          if (i < n) {
            fields = "$fields,";
            values = "$values,";
          }
          i++;
        }
        final String q = "INSERT INTO $table ($fields) VALUES($values)";
        await _db.transaction((txn) async {
          id = await txn.rawInsert(q, datapoint);
        });
        final String qStr = "$q $row";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.insert,
            value: 1,
            query: qStr,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          final String msg = "$q in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
      } on DatabaseNotReady catch (e) {
        throw ("${e.message}");
      } catch (e) {
        throw (e);
      }
    });
    return id;
  }

  /// Update some datapoints in the database
  Future<int> update(
      {@required String table,
      @required Map<String, String> row,
      @required String where,
      bool verbose = false}) async {
    /// [table] is the table to use, [row] is a map of the data to update
    /// and [where] the sql where clause
    ///
    /// Returns a future with a count of the updated rows
    int updated = 0;
    await _mutex.synchronized(() async {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      try {
        String pairs = "";
        final int n = row.length - 1;
        int i = 0;
        final List<String> datapoint = [];
        for (final el in row.keys) {
          pairs = "$pairs$el= ?";
          datapoint.add(row[el]);
          if (i < n) {
            pairs = "$pairs, ";
          }
          i++;
        }
        final String q = 'UPDATE $table SET $pairs WHERE $where';
        await _db.transaction((txn) async {
          updated = await txn.rawUpdate(q, datapoint);
        });
        final String qStr = "$q $datapoint";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.update,
            value: updated,
            query: qStr,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          final String msg = "$q $row in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
        return updated;
      } on DatabaseNotReady catch (e) {
        throw ("${e.message}");
      } catch (e) {
        throw (e);
      }
    });
    return updated;
  }

  /// Insert a row if it does not exist or update it
  ///
  /// It is highly recommended to use an unique index for the table
  /// to upsert into
  Future<void> upsert(
      {@required String table,
      @required Map<String, String> row,
      //@required List<String> columns,
      List<String> preserveColumns = const [],
      String indexColumn,
      bool verbose = false}) async {
    /// The [preserveColumns] is used to keep the current values
    /// for some columns. If this parameter is used an [indexColumn]
    /// must be provided to search for the value of the column to preserve
    await _mutex.synchronized(() async {
      if (!_isReady) throw DatabaseNotReady();
      if (preserveColumns.isNotEmpty) {
        if (indexColumn == null)
          throw ArgumentError("Please provide a value for indexColumn " +
              "if you use preserveColumns");
      }
      try {
        final Stopwatch timer = Stopwatch()..start();
        String fields = "";
        String values = "";
        //String pairs = "";
        preserveColumns.forEach((c) {
          row[c] = "";
        });
        final int n = row.length;
        int i = 1;
        for (final k in row.keys) {
          fields += "$k";
          if (preserveColumns.contains(k)) {
            values += "(SELECT $k FROM $table WHERE " +
                "$indexColumn='${row[indexColumn]}')";
          } else {
            values += "'${row[k]}'";
          }
          //pairs += "$k='${row[k]}'";
          if (i < n) {
            fields += ",";
            values += ",";
            //pairs += ",";
          }
          i++;
        }
        // This only works for Sqlite > 3.24
        /*
        String q = "INSERT INTO $table ($fields) VALUES($values)";
        q += " ON CONFLICT($columns) DO UPDATE SET $pairs";*/
        final String q =
            "INSERT OR REPLACE INTO $table ($fields) VALUES($values)";
        await _db.transaction((txn) async {
          await txn.execute(q);
        });
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.upsert,
            value: i,
            query: q,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) print("$q in ${timer.elapsedMilliseconds} ms");
      } on DatabaseNotReady catch (e) {
        throw ("${e.message}");
      } catch (e) {
        throw (e);
      }
    });
  }

  /// Delete some datapoints from the database
  Future<int> delete(
      {@required String table,
      @required String where,
      bool verbose = false}) async {
    /// [table] is the table to use and [where] the sql where clause
    ///
    /// Returns a future with a count of the deleted rows
    int deleted = 0;
    await _mutex.synchronized(() async {
      if (!_isReady) throw DatabaseNotReady();
      try {
        final Stopwatch timer = Stopwatch()..start();
        final String q = 'DELETE FROM $table WHERE $where';
        await _db.transaction((txn) async {
          deleted = await txn.rawDelete(q);
        });
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.delete,
            value: deleted,
            query: q,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          final String msg = "$q in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
        return deleted;
      } on DatabaseNotReady catch (e) {
        throw ("${e.message}");
      } catch (e) {
        throw (e);
      }
    });
    return deleted;
  }

  /// Check if a value exists in the table
  Future<bool> exists(
      {@required String table,
      @required String where,
      bool verbose = false}) async {
    /// [table] is the table to use and [where] the sql where clause
    ///
    /// Returns a future with true if the data exists
    try {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      final String q = 'SELECT COUNT(*) FROM $table WHERE $where';
      int count;
      await _db.transaction((txn) async {
        count = Sqflite.firstIntValue(await txn.rawQuery(q));
      });
      timer.stop();
      if (verbose) {
        final String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      if (count > 0) return true;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
    return false;
  }

  /// count rows in a table
  Future<int> count(
      {@required String table,
      String where,
      String columns = "id",
      bool verbose = false}) async {
    /// [table] is the table to use and [where] the sql where clause
    ///
    /// Returns a future with the count of the rows
    try {
      if (!_isReady) throw DatabaseNotReady();
      final Stopwatch timer = Stopwatch()..start();
      String w = "";
      if (where != null) w = " WHERE $where";
      final String q = 'SELECT COUNT($columns) FROM $table$w';
      int c;
      await _db.transaction((txn) async {
        c = Sqflite.firstIntValue(await txn.rawQuery(q));
      });
      timer.stop();
      if (verbose) {
        final String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return c;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
  }

  /// Insert rows in a table
  Future<void> batchInsert(
      {@required String table,
      @required List<Map<String, String>> rows,
      ConflictAlgorithm confligAlgoritm = ConflictAlgorithm.rollback,
      bool verbose = false}) async {
    await _mutex.synchronized(() async {
      try {
        if (!_isReady) throw DatabaseNotReady();
        final Stopwatch timer = Stopwatch()..start();
        await _db.transaction((txn) async {
          final batch = txn.batch();
          rows.forEach((row) {
            batch.insert(table, row, conflictAlgorithm: confligAlgoritm);
            _changeFeedController.sink.add(DatabaseChangeEvent(
                type: DatabaseChange.insert,
                value: 1,
                query: "",
                table: table,
                executionTime: timer.elapsedMicroseconds));
          });
          await batch.commit();
        });
        timer.stop();
        if (verbose) {
          final String msg = "Inserted ${rows.length} records " +
              "in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
      } on DatabaseNotReady catch (e) {
        throw ("${e.message}");
      } catch (e) {
        throw (e);
      }
    });
  }
}
