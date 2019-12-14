import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

import 'exceptions.dart';
import 'models.dart';
import 'schema/models/schema.dart';
import 'schema/models/table.dart';

/// A class to handle database operations
class Db {
  /// An Sqlite database:
  ///
  /// Use this parameter if you want to work with an existing
  /// Sqflite database
  final Database sqfliteDatabase;

  Database _db;

  final _mutex = Lock();

  final Completer<void> _readyCompleter = Completer<void>();
  final StreamController<DatabaseChangeEvent> _changeFeedController =
      StreamController<DatabaseChangeEvent>.broadcast();
  File _dbFile;
  bool _isReady = false;
  final _schema = DbSchema();

  /// An empty database. Has to be initialized with [init]
  Db({this.sqfliteDatabase}) {
    if (sqfliteDatabase != null) {
      _db = sqfliteDatabase;
      _dbFile = File(sqfliteDatabase.path);
      _isReady = true;
      _readyCompleter.complete();
    }
  }

  /// A stream of [DatabaseChangeEvent] with all the changes
  /// that occur in the database
  Stream<DatabaseChangeEvent> get changefeed => _changeFeedController.stream;

  /// This Sqflite [Database]
  Database get database => _db;

  /// This Sqlite file
  File get file => _dbFile;

  /// Check the existence of a schema
  bool get hasSchema => _schema != null;

  /// This database state
  bool get isReady => _isReady;

  /// The on ready callback: fired when the database
  /// is ready to operate
  Future<void> get onReady => _readyCompleter.future;

  /// This database schema
  DbSchema get schema => _schema;

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
    /*if (fromAsset == null && queries.isEmpty && schema.isEmpty) {
      throw ArgumentError("Either a [queries] or a [schema] must be provided");
    }*/
    if (debug) {
      await Sqflite.setDebugModeOn(true);
    }
    var dbpath = path;
    if (!absolutePath) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      dbpath = documentsDirectory.path + "/" + path;
    }
    if (verbose) {
      print("INITIALIZING DATABASE at " + dbpath);
    }
    // copy the database from an asset if necessary
    var checkCreateQueries = false;
    if (fromAsset != null) {
      final file = File(dbpath);
      if (!file.existsSync()) {
        if (verbose) {
          print("Copying the database from asset $fromAsset");
        }
        List<int> bytes;
        try {
          // read
          final data = await rootBundle.load("$fromAsset");
          bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        } catch (e) {
          throw DatabaseAssetProblem("Unable to read database from asset: $e");
        }
        try {
          // create the directories path if necessary
          if (!file.parent.existsSync()) {
            file.parent.createSync(recursive: true);
          }
          // write
          await file.writeAsBytes(bytes);
          checkCreateQueries = true;
        } catch (e) {
          throw DatabaseAssetProblem("Unable to write database from asset: $e");
        }
      }
    }
    if (this._db == null) {
      await _mutex.synchronized(() async {
        // open
        if (verbose) {
          print("OPENING database");
        }
        this._db = await openDatabase(dbpath, version: 1,
            onCreate: (Database _sqfliteDb, int version) async {
          await _initQueries(schema, queries, _sqfliteDb, verbose);
        }, onOpen: (Database _sqfliteDb) async {
          // run create queries for file copied from an asset
          if (fromAsset != null && checkCreateQueries) {
            if (schema != null || queries.isNotEmpty) {
              await _initQueries(schema, queries, _sqfliteDb, verbose);
            }
          }
        });
      });
    }
    if (verbose) {
      print("DATABASE INITIALIZED");
    }
    _dbFile = File(dbpath);
    // set internal schema
    _schema.tables = schema.toSet();
    // the database is ready to use
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
    _isReady = true;
  }

  /// Insert a row in a table if it is not present already
  ///
  /// [table] the table to insert into. [row] is a map of the data
  /// to insert
  ///
  /// Returns a future with the last inserted id
  Future<int> insertIfNotExists(
      {@required String table,
      @required Map<String, String> row,
      bool verbose = false}) async {
    return _insert(table: table, row: row, ifNotExists: true, verbose: verbose);
  }

  /// Insert a row in a table
  ///
  /// [table] the table to insert into. [row] is a map of the data
  /// to insert
  ///
  /// Returns a future with the last inserted id
  Future<int> insert(
      {@required String table,
      @required Map<String, String> row,
      bool verbose = false}) async {
    return _insert(table: table, row: row, verbose: verbose);
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
      @required Map<String, dynamic> row,
      bool verbose = false}) async {
    int id;
    try {
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      await _db.transaction((txn) async {
        id = await txn.insert(table, row, conflictAlgorithm: conflictAlgorithm);
      });
    } catch (e) {
      throw WriteQueryException("Can not insert in table $table: $e");
    }
    return id;
  }

  Future<int> _insert(
      {@required String table,
      @required Map<String, String> row,
      bool ifNotExists = false,
      bool verbose = false}) async {
    int id;
    await _mutex.synchronized(() async {
      try {
        if (!_isReady) {
          throw DatabaseNotReady();
        }
        final timer = Stopwatch()..start();
        var fields = "";
        var values = "";
        final n = row.length;
        var i = 1;
        final datapoint = <String>[];
        for (final k in row.keys) {
          final buf = StringBuffer("$fields")..write("$k");
          fields = buf.toString();
          final buf2 = StringBuffer("$values")..write("?");
          values = buf2.toString();
          datapoint.add(row[k]);
          if (i < n) {
            fields = "$fields,";
            values = "$values,";
          }
          i++;
        }
        var q = "INSERT INTO $table ($fields) VALUES($values)";
        if (ifNotExists) {
          var where = "";
          var i = 0;
          row.forEach((k, v) {
            if (i > 0) {
              where += " AND ";
            }
            var val = v;
            final isNum = num.tryParse(v) != null;
            if (!isNum) {
              val = '"$v"';
            }
            where += '$k=$val';
            ++i;
          });
          q += " IF NOT EXISTS (SELECT id from $table WHERE $where) LIMIT 1";
        }
        await _db.transaction((txn) async {
          id = await txn.rawInsert(q, datapoint);
        }).catchError((dynamic e) {
          throw WriteQueryException("Can not insert in table $table: $e");
        });
        final qStr = "$q $row";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.insert,
            value: 1,
            data: row,
            query: qStr,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          final msg = "$q $row in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
      } catch (e) {
        rethrow;
      }
    });
    return id;
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
          bool verbose = false}) async =>
      _join(
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

  /// A select query with a join on multiple tables
  Future<List<Map<String, dynamic>>> mJoin(
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
    /// [table] the table to select from
    /// [joinsTables] the tables to join from
    /// [joinsOn] the columns to join
    /// [columns] the columns to return
    /// [where] the sql where clause
    /// [orderBy] the sql order_by clause
    /// [limit] the sql limit clause
    /// [offset] the sql offset clause
    /// [verbose] print the query
    /// returns the selected data
    if (!_isReady) {
      throw DatabaseNotReady();
    }
    final timer = Stopwatch()..start();
    var q = "SELECT $columns FROM $table";
    var i = 0;
    joinsTables.forEach((_) {
      q = "$q INNER JOIN ${joinsTables[i]} ON ${joinsOn[i]}";
      ++i;
    });

    if (where != null) {
      q += " WHERE $where";
    }
    if (groupBy != null) {
      q += " GROUP BY $groupBy";
    }
    if (orderBy != null) {
      q += " ORDER BY $orderBy";
    }
    if (limit != null) {
      q += " LIMIT $limit";
    }
    if (offset != null) {
      q += " OFFSET $offset";
    }
    List<Map<String, dynamic>> res;
    await _db.transaction((txn) async {
      res = await txn.rawQuery(q);
    }).catchError((dynamic e) {
      throw ReadQueryException("Join query error: $e");
    });
    timer.stop();
    if (verbose) {
      final msg = "$q in ${timer.elapsedMilliseconds} ms";
      print(msg);
    }
    return res;
  }

  /// Execute a query
  Future<List<Map<String, dynamic>>> query(String q,
      {bool verbose = false}) async {
    /// [q] the query to execute
    try {
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      final timer = Stopwatch()..start();
      List<Map<String, dynamic>> res;
      await _db.transaction((txn) async {
        res = await txn.rawQuery(q);
      }).catchError((dynamic e) =>
          throw RawQueryException("Can not execute query $q $e"));
      timer.stop();
      if (verbose) {
        final msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return res;
    } catch (e) {
      rethrow;
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
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      final timer = Stopwatch()..start();
      var q = "SELECT $columns FROM $table";
      if (where != null) {
        q += " WHERE $where";
      }
      if (groupBy != null) {
        q += " GROUP BY $groupBy";
      }
      if (orderBy != null) {
        q += " ORDER BY $orderBy";
      }
      if (limit != null) {
        q += " LIMIT $limit";
      }
      if (offset != null) {
        q += " OFFSET $offset";
      }
      List<Map<String, dynamic>> res;
      await _db.transaction((txn) async {
        res = await txn.rawQuery(q);
      }).catchError((dynamic e) =>
          throw ReadQueryException("Can not select from table $table $e"));
      timer.stop();
      if (verbose) {
        final msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return res;
    } catch (e) {
      rethrow;
    }
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
    var updated = 0;
    await _mutex.synchronized(() async {
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      final timer = Stopwatch()..start();
      try {
        var pairs = "";
        final n = row.length - 1;
        var i = 0;
        final datapoint = <String>[];
        final buf = StringBuffer();
        for (final el in row.keys) {
          buf..write("$pairs")..write("$el")..write("= ?");
          pairs = buf.toString();
          datapoint.add(row[el]);
          if (i < n) {
            pairs = ", ";
          }
          i++;
        }
        final q = 'UPDATE $table SET $pairs WHERE $where';
        await _db.transaction((txn) async {
          updated = await txn.rawUpdate(q, datapoint);
        }).catchError((dynamic e) => throw WriteQueryException(
            "Can not update data in table $table $e"));
        final qStr = "$q $datapoint";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.update,
            value: updated,
            query: qStr,
            table: table,
            data: row,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          final msg = "$q $row in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
        return updated;
      } catch (e) {
        rethrow;
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
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      if (preserveColumns.isNotEmpty) {
        if (indexColumn == null) {
          throw ArgumentError("Please provide a value for indexColumn "
              "if you use preserveColumns");
        }
      }
      try {
        final timer = Stopwatch()..start();
        var fields = "";
        var values = "";
        preserveColumns.forEach((c) {
          row[c] = "";
        });
        final n = row.length;
        var i = 1;
        final fieldsBuf = StringBuffer();
        final valuesBuf = StringBuffer();
        for (final k in row.keys) {
          fieldsBuf.write("$k");
          if (preserveColumns.contains(k)) {
            valuesBuf.write("(SELECT $k FROM $table WHERE "
                "$indexColumn='${row[indexColumn]}')");
          } else {
            valuesBuf.write("'${row[k]}'");
          }
          //pairs += "$k='${row[k]}'";
          if (i < n) {
            //fields += ",";
            fieldsBuf.write(",");
            valuesBuf.write(",");
            //pairs += ",";
          }
          i++;
        }
        fields = fieldsBuf.toString();
        values = valuesBuf.toString();
        // This only works for Sqlite > 3.24
        /*
        String q = "INSERT INTO $table ($fields) VALUES($values)";
        q += " ON CONFLICT($columns) DO UPDATE SET $pairs";*/
        final q = "INSERT OR REPLACE INTO $table ($fields) VALUES($values)";
        await _db.transaction((txn) async {
          await txn.execute(q);
        }).catchError((dynamic e) =>
            throw WriteQueryException("Can not upsert into table $table $e"));
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.upsert,
            value: i,
            query: q,
            table: table,
            data: row,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          print("$q $row in ${timer.elapsedMilliseconds} ms");
        }
      } catch (e) {
        rethrow;
      }
    });
  }

  /// Insert rows in a table
  Future<List<dynamic>> batchInsert(
      {@required String table,
      @required List<Map<String, String>> rows,
      ConflictAlgorithm confligAlgoritm = ConflictAlgorithm.rollback,
      bool verbose = false}) async {
    var res = <dynamic>[];
    await _mutex.synchronized(() async {
      try {
        if (!_isReady) {
          throw DatabaseNotReady();
        }
        final timer = Stopwatch()..start();

        await _db.transaction((txn) async {
          final batch = txn.batch();
          rows.forEach((row) {
            batch.insert(table, row, conflictAlgorithm: confligAlgoritm);
            _changeFeedController.sink.add(DatabaseChangeEvent(
                type: DatabaseChange.insert,
                value: 1,
                query: "",
                table: table,
                data: row,
                executionTime: timer.elapsedMicroseconds));
          });
          res = await batch.commit();
        });
        timer.stop();
        if (verbose) {
          final msg = "Inserted ${rows.length} records "
              "in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
      } catch (e) {
        rethrow;
      }
    });
    return res;
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
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      final timer = Stopwatch()..start();
      var w = "";
      if (where != null) {
        w = " WHERE $where";
      }
      final q = 'SELECT COUNT($columns) FROM $table$w';
      int c;
      await _db.transaction((txn) async {
        c = Sqflite.firstIntValue(await txn.rawQuery(q));
      });
      timer.stop();
      if (verbose) {
        final msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return c;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete some datapoints from the database
  Future<int> delete(
      {@required String table,
      @required String where,
      bool verbose = false}) async {
    /// [table] is the table to use and [where] the sql where clause
    ///
    /// Returns a future with a count of the deleted rows
    var deleted = 0;
    await _mutex.synchronized(() async {
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      try {
        final timer = Stopwatch()..start();
        final q = 'DELETE FROM $table WHERE $where';
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
          final msg = "$q in ${timer.elapsedMilliseconds} ms";
          print(msg);
        }
        return deleted;
      } catch (e) {
        rethrow;
      }
    });
    return deleted;
  }

  /// Dispose the changefeed stream when finished using
  void dispose() {
    _changeFeedController.close();
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
      if (!_isReady) {
        throw DatabaseNotReady();
      }
      final timer = Stopwatch()..start();
      final q = 'SELECT COUNT(*) FROM $table WHERE $where';
      int count;
      await _db.transaction((txn) async {
        count = Sqflite.firstIntValue(await txn.rawQuery(q));
      });
      timer.stop();
      if (verbose) {
        final msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      if (count > 0) {
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<void> _initQueries(List<DbTable> schema, List<String> queries,
      Database _sqfliteDb, bool verbose) async {
    var _queries = queries;
    if (schema != null) {
      final schemaQueries = <String>[];
      schema
          .forEach((tableSchema) => schemaQueries.addAll(tableSchema.queries));
      schemaQueries.addAll(queries);
      _queries = schemaQueries;
    }
    if (_queries.isNotEmpty) {
      await _sqfliteDb.transaction((txn) async {
        for (final q in _queries) {
          final timer = Stopwatch()..start();
          await txn.execute(q);
          timer.stop();
          if (verbose) {
            final msg = "$q in ${timer.elapsedMilliseconds} ms";
            print(msg);
          }
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> _join(
      {@required String table,
      @required String joinTable,
      @required String joinOn,
      String columns = "*",
      int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool byPassReady = false,
      bool verbose = false}) async {
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
    if (!byPassReady && !_isReady) {
      throw DatabaseNotReady();
    }
    final timer = Stopwatch()..start();
    var q = "SELECT $columns FROM $table";
    q = "$q INNER JOIN $joinTable ON $joinOn";
    if (where != null) {
      q += " WHERE $where";
    }
    if (groupBy != null) {
      q += " GROUP BY $groupBy";
    }
    if (orderBy != null) {
      q += " ORDER BY $orderBy";
    }
    if (limit != null) {
      q += " LIMIT $limit";
    }
    if (offset != null) {
      q += " OFFSET $offset";
    }
    List<Map<String, dynamic>> res;
    await _db.transaction((txn) async {
      res = await txn.rawQuery(q).catchError((dynamic e) {
        throw ReadQueryException("Join query error: $e");
      });
    });
    timer.stop();
    if (verbose) {
      final msg = "$q in ${timer.elapsedMilliseconds} ms";
      print(msg);
    }
    return res;
  }
}
