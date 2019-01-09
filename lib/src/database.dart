import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:synchronized/synchronized.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Db db = Db();

class Db {
  Db();

  Database database;
  final _lock = new Lock();

  Future<void> init(String path,
      {List<String> queries: const <String>[],
      bool verbose: false,
      String fromAsset: ""}) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbpath = documentsDirectory.path + "/" + path;
    if (verbose == true) {
      print("INITIALIZING DATABASE at " + dbpath);
    }

    // copy the database from an asset if necessary
    if (fromAsset != "") {
      bool exists = await File(dbpath).exists();
      if (exists == false) {
        if (verbose == true) {
          print("Copying the database from asset $fromAsset");
        }
        try {
          // copy asset
          // read
          ByteData data = await rootBundle.load("$fromAsset");
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          // write
          await new File(dbpath).writeAsBytes(bytes);
        } catch (e) {
          throw ("Unable to copy database: $e");
        }
      }
    }
    if (this.database == null) {
      await _lock.synchronized(() async {
        if (this.database == null) {
          // open
          if (verbose == true) {
            print("OPENING DATABASE");
          }
          this.database = await openDatabase(dbpath, version: 1,
              onCreate: (Database _db, int version) async {
            if (queries.length > 0) {
              if (verbose == true) {
                print("CREATING TABLES");
              }
              for (String q in queries) {
                await _db.execute(q);
              }
              if (verbose == true) {
                print("Created tables");
              }
            }
          });
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> select(String table,
      {String columns = "*",
      String where,
      String orderBy,
      int limit,
      int offset,
      verbose: false}) async {
    try {
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
      if (verbose == true) {
        print(q);
      }
      final List<Map<String, dynamic>> res = await this.database.rawQuery(q);
      return res.toList();
    } catch (e) {
      throw (e);
    }
  }

  Future<List<Map<String, dynamic>>> join(
      String table, String select, String joinTable, String joinOn,
      {int offset = 0, int limit = 100, String where = ""}) async {
    try {
      String q = "SELECT $select FROM $table";
      q = "$q INNER JOIN $joinTable ON $joinOn";
      q = "$q LIMIT $limit OFFSET $offset";
      if (where != "") {
        q = q + " WHERE $where";
      }
      final List<Map<String, dynamic>> res = await this.database.rawQuery(q);
      return res.toList();
    } catch (e) {
      // TODO : error handling
      print(e);
      final res = <Map<String, dynamic>>[];
      return res;
    }
  }

  Future<void> insert(String table, Map<String, String> row,
      {bool verbose: false}) async {
    /// insert a row in the table
    if (verbose == true) {
      print("INSERTING DATAPOINT in $table");
    }
    // insert
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
    if (verbose == true) {
      print("$q $datapoint");
    }
    this.database.rawInsert(q, datapoint).catchError((e) {
      throw (e);
    });
  }

  Future<bool> exists(String table, String where) async {
    /// check if a value exists in the table
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM $table WHERE $where'));
    if (count > 0) {
      return true;
    }
    return false;
  }

  Future<int> update(String table, Map<String, String> row, String where,
      {bool verbose = false}) async {
    /// update some datapoints in the database
    /// returns a count of the updated rows
    if (verbose == true) {
      print("UPDATING DATAPOINT in $table");
    }
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
      int updated = await this.database.rawUpdate(q, datapoint);
      return updated;
    } catch (e) {
      throw (e);
    }
  }

  Future<int> delete(String table, String where, {bool verbose: false}) async {
    /// delete some datapoints from the database
    /// returns a count of the deleted rows
    if (verbose == true) {
      print("DELETING FROM TABLE $table");
    }
    try {
      int count =
          await this.database.rawDelete('DELETE FROM $table WHERE $where');
      return count;
    } catch (e) {
      throw (e);
    }
  }
}
