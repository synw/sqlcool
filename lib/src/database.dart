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

/// A class to handle database operations
class Db {
  /// An empty database. Has to be initialized with [init]
  Db();

  Database _db;

  final _mutex = new Lock();
  final Completer<Null> _readyCompleter = Completer<Null>();
  final StreamController<DatabaseChangeEvent> _changeFeedController =
      StreamController<DatabaseChangeEvent>.broadcast();
  File _dbFile;
  bool _isReady = false;

  /// The on ready callback: fired when the database
  /// is ready to operate
  Future<Null> get onReady => _readyCompleter.future;

  /// A stream of [DatabaseChangeEvent] with all the changes
  /// that occur in the database
  Stream<DatabaseChangeEvent> get changefeed => _changeFeedController.stream;

  /// the Sqlite file
  File get file => _dbFile;

  /// A Sqflite database
  Database get database => _db;

  /// The database state
  bool get isReady => _isReady;

  /// Dispose the changefeed stream
  void dispose() {
    _changeFeedController.close();
  }

  /// Initialize the database
  ///
  /// The database can be initialized either from an asset file
  /// with the [fromAsset] parameter or from some create table queries
  /// with the [queries] parameter.
  Future<void> init(
      {@required String path,
      bool absolutePath = false,
      List<String> queries = const <String>[],
      bool verbose = false,
      String fromAsset = "",
      bool debug = false}) async {
    /// The [path] is where the database file will be stored. It is by
    /// default relative to the documents directory unless [absolutePath]
    /// is true.
    /// [queries] is a list of queries to run at initialization
    /// and [debug] set Sqflite debug mode on
    assert(path != null);
    if (debug) Sqflite.setDebugModeOn(true);
    String dbpath = path;
    if (!absolutePath) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      dbpath = documentsDirectory.path + "/" + path;
    }
    if (verbose) {
      print("INITIALIZING DATABASE at " + dbpath);
    }
    // copy the database from an asset if necessary
    if (fromAsset != "") {
      File file = File(dbpath);
      if (!file.existsSync()) {
        if (verbose) {
          print("Copying the database from asset $fromAsset");
        }
        List<int> bytes;
        try {
          // read
          ByteData data = await rootBundle.load("$fromAsset");
          bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        } catch (e) {
          throw ("Unable to read database from asset: $e");
        }
        try {
          // create the directories path if necessary
          if (!file.parent.existsSync()) {
            file.parent.createSync(recursive: true);
          }
          // write
          await file.writeAsBytes(bytes);
        } catch (e) {
          throw ("Unable to write database from asset: $e");
        }
      }
    }
    if (this._db == null) {
      await _mutex.synchronized(() async {
        if (this._db == null) {
          // open
          if (verbose) {
            print("OPENING database");
          }
          this._db = await openDatabase(dbpath, version: 1,
              onCreate: (Database _db, int version) async {
            if (queries.isNotEmpty) {
              for (String q in queries) {
                Stopwatch timer = Stopwatch()..start();
                await _db.execute(q);
                if (verbose) {
                  String msg = "$q in ${timer.elapsedMilliseconds} ms";
                  print(msg);
                }
              }
            }
          });
        }
      });
    }
    if (verbose) {
      print("DATABASE INITIALIZED");
    }
    _dbFile = File(dbpath);
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
    _isReady = true;
  }

  /// Execute a query
  Future<List<Map<String, dynamic>>> query(String q,
      {bool verbose = false}) async {
    /// [q] the query to execute
    try {
      if (!_isReady) throw DatabaseNotReady();
      Stopwatch timer = Stopwatch()..start();
      final List<Map<String, dynamic>> res = await this._db.rawQuery(q);
      timer.stop();
      if (verbose) {
        String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
      Stopwatch timer = Stopwatch()..start();
      String q = "SELECT $columns FROM $table";
      if (where != null) {
        q += " WHERE $where";
      }
      if (orderBy != null) {
        q = "$q ORDER BY $orderBy";
      }
      if (limit != null) {
        q += " LIMIT $limit";
      }
      if (offset != null) {
        q += " OFFSET $offset";
      }
      final List<Map<String, dynamic>> res = await this._db.rawQuery(q);
      timer.stop();
      if (verbose) {
        String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
      int offset = 0,
      int limit = 100,
      String orderBy,
      String where,
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
      Stopwatch timer = Stopwatch()..start();
      String q = "SELECT $columns FROM $table";
      q = "$q INNER JOIN $joinTable ON $joinOn";
      if (where != null) {
        q = q + " WHERE $where";
      }
      if (orderBy != null) {
        q = "$q ORDER BY $orderBy";
      }
      if (limit != null) {
        q += " LIMIT $limit";
      }
      if (offset != null) {
        q += " OFFSET $offset";
      }
      final List<Map<String, dynamic>> res = await this._db.rawQuery(q);
      timer.stop();
      if (verbose) {
        String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
        Stopwatch timer = Stopwatch()..start();
        String fields = "";
        String values = "";
        int n = row.length;
        int i = 1;
        List<String> datapoint = [];
        for (var k in row.keys) {
          fields = "$fields$k";
          values = "$values?";
          datapoint.add(row[k]);
          if (i < n) {
            fields = "$fields,";
            values = "$values,";
          }
          i++;
        }
        String q = "INSERT INTO $table ($fields) VALUES($values)";
        id = await _db.rawInsert(q, datapoint);
        String qStr = "$q $row";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.insert,
            value: 1,
            query: qStr,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
      Stopwatch timer = Stopwatch()..start();
      try {
        String pairs = "";
        int n = row.length - 1;
        int i = 0;
        List<String> datapoint = [];
        for (var el in row.keys) {
          pairs = "$pairs$el= ?";
          datapoint.add(row[el]);
          if (i < n) {
            pairs = "$pairs, ";
          }
          i++;
        }
        String q = 'UPDATE $table SET $pairs WHERE $where';
        updated = await this._db.rawUpdate(q, datapoint);
        String qStr = "$q $datapoint";
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.update,
            value: updated,
            query: qStr,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
        Stopwatch timer = Stopwatch()..start();
        String q = 'DELETE FROM $table WHERE $where';
        int deleted = await this._db.rawDelete(q);
        timer.stop();
        _changeFeedController.sink.add(DatabaseChangeEvent(
            type: DatabaseChange.delete,
            value: deleted,
            query: q,
            table: table,
            executionTime: timer.elapsedMicroseconds));
        if (verbose) {
          String msg = "$q in ${timer.elapsedMilliseconds} ms";
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
      Stopwatch timer = Stopwatch()..start();
      String q = 'SELECT COUNT(*) FROM $table WHERE $where';
      int count = Sqflite.firstIntValue(await _db.rawQuery(q));
      timer.stop();
      if (verbose) {
        String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      if (count > 0) {
        return true;
      }
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
    return false;
  }

  /// count rows in a table
  Future<int> count(
      {@required String table, String where, bool verbose = false}) async {
    /// [table] is the table to use and [where] the sql where clause
    ///
    /// Returns a future with the count of the rows
    try {
      if (!_isReady) throw DatabaseNotReady();
      Stopwatch timer = Stopwatch()..start();
      String w = "";
      if (where != null) {
        w = " WHERE $where";
      }
      String q = 'SELECT COUNT(*) FROM $table$w';
      final int c = Sqflite.firstIntValue(await this._db.rawQuery(q));
      timer.stop();
      if (verbose) {
        String msg = "$q in ${timer.elapsedMilliseconds} ms";
        print(msg);
      }
      return c;
    } on DatabaseNotReady catch (e) {
      throw ("${e.message}");
    } catch (e) {
      throw (e);
    }
  }
}
