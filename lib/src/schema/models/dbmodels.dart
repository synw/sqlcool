import 'dart:async';

import '../../database.dart';
import '../../exceptions.dart';
import 'column.dart';
import 'table.dart';

/// The database model class to extend
class DbModel {
  /// The database id of the model instance
  ///
  /// **Important** : it must be overriden
  int? id;

  /// get the database
  Db? get db => null;

  /// get the table schema
  DbTable? get table => null;

  /// The database row serializer for the model
  ///
  /// **Important** : it must be overriden
  Map<String, dynamic> toDb() => <String, dynamic>{};

  /// The database row deserializer for the model
  ///
  /// **Important** : it must be overriden
  DbModel? fromDb(final Map<String, dynamic> map) => null;

  /// Select rows in the database table with joins on foreign keys
  Future<List<dynamic>?> sqlJoin(
      {final int? offset,
      final int? limit,
      final String? orderBy,
      final String? where,
      final String? groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    print("> Sqljoin for table $table");
    //table.describe();
    final _joinTables = <String>[];
    final _joinOn = <String>[];
    final _select = <String>[];
    final _encodedFks = <_EncodedFk>[];
    final _table = table;
    final _db = db;

    if (_db != null && _table != null) {
      if (!_table.hasColumn("id")) {
        _table.columns.add(const DbColumn(name: "id", type: DbColumnType.integer));
      }
      _table.columns.forEach((final c) {
        if (!c.isForeignKey) {
          _select.add("${_table.name}.${c.name} AS ${c.name}");
        }
      });
      for (final fkCol in _table.foreignKeys) {
        final fkTable = _db.schema.table(fkCol.reference);
        if (fkTable != null) {
          _joinTables.add(fkTable.name);
          //print("FK COLS $fkTable: ${fkTable.columns}");
          final c = fkTable.columns;
          if (!fkTable.hasColumn("id")) {
            c.add(const DbColumn(name: "id", type: DbColumnType.integer));
          }

          //print("NEW FK COLS ${fkTable.columns}");
          _joinOn.add("${_table.name}.${fkCol.name}=${fkTable.name}.id");
          //print("Joins add ${table.name}.${fkCol.name}=${fkTable.name}.id");
          for (final _fkTableCol in c) {
            final encodedName = "${fkTable.name}_${_fkTableCol.name}";
            final fk =
                _EncodedFk(table: fkTable, name: _fkTableCol.name, encodedName: encodedName, refColName: fkCol.name);
            _encodedFks.add(fk);
            final encodedFkName = "${fkTable.name}.${fk.name} AS $encodedName";
            _select.add(encodedFkName);
          }
        }
      }

      final columns = _select.join(",");
      final res = await _db.mJoin(
          table: _table.name,
          joinsTables: _joinTables,
          joinsOn: _joinOn,
          columns: columns,
          offset: offset,
          limit: limit,
          where: where,
          groupBy: groupBy,
          verbose: verbose);

      final endRes = <Map<String, dynamic>>[];
      //print("\nRES $res\n");
      if (res != null) {
        for (final row in res) {
          final endRow = <String, dynamic>{};
          final fkData = <String, Map<String, dynamic>>{};
          row.forEach((final String key, final dynamic value) {
            final encodedFk = _encodedFks.where((final element) => element.encodedName == key).toList();
            if (encodedFk.isEmpty) {
              // it is not a foreign key
              endRow[key] = value;
            } else {
              final efk = encodedFk[0];
              //print("EFK $efk");
              if (!fkData.containsKey(efk.refColName)) {
                fkData[efk.refColName] = <String, dynamic>{};
              }
              fkData[efk.refColName]![efk.name] = value;
              //endRow[key][encodedFk[0].refColName] = value;
              //print("FKDATA : $fkData");
            }
          });
          for (final c in fkData.keys) {
            //print("FK DATA $c : ${fkData[c]}");
            endRow[c] = fkData[c];
          }
          //print("END ROW $endRow");
          endRes.add(endRow);
        }
      }

      //print("QUERY END RES: $endRes");
      final endModelData = <dynamic>[];
      for (final r in endRes) {
        endModelData.add(fromDb(r));
      }
      //print("End model data: $endModelData");
      return endModelData;
    }
    return null;
  }

  /// Select rows in the database table
  Future<List<dynamic>?> sqlSelect(
      {final String? where,
      final String? orderBy,
      final int? limit,
      final int? offset,
      final String? groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    // do not take the foreign keys
    final _table = table;
    final _db = db;

    if (_db != null && _table != null) {
      final cols = <String>["id"];
      for (final col in _table.columns) {
        if (!col.isForeignKey) {
          cols.add(col.name);
        }
      }
      final columns = cols.join(",");
      final res = await _db.select(
          table: _table.name,
          columns: columns,
          where: where,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
          groupBy: groupBy,
          verbose: verbose);
      final endRes = <dynamic>[];
      if (res != null) {
        for (final row in res) {
          endRes.add(fromDb(row));
        }
        return endRes;
      }
    }
    return null;
  }

  /// Update a row in the database table
  Future<void> sqlUpdate({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      await _db
          .update(table: _table.name, row: row, where: 'id=$id', verbose: verbose)
          .catchError((final dynamic e) => throw WriteQueryException("Can not update model into database $e"));
    }
  }

  /// Upsert a row in the database table
  Future<void> sqlUpsert(
      {bool verbose = false, final String? indexColumn, List<String> preserveColumns = const <String>[]}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      await _db
          .upsert(
              table: _table.name,
              row: row,
              indexColumn: indexColumn,
              preserveColumns: preserveColumns,
              verbose: verbose)
          .catchError((final dynamic e) => throw WriteQueryException("Can not upsert model into database $e"));
    }
  }

  /// Insert a row in the database table
  Future<int?> sqlInsert({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      final id = await _db
          .insert(table: _table.name, row: row, verbose: verbose)
          .catchError((final dynamic e) => throw WriteQueryException("Can not insert model into database $e"));
      return id;
    }

    return null;
  }

  /// Insert a row in the database table if it does not exist already
  @Deprecated("The insertIfNotExists function will be removed after version 4.4.0")
  Future<int?> sqlInsertIfNotExists({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      final id = await _db
          .insertIfNotExists(table: _table.name, row: row, verbose: verbose)
          .catchError((final dynamic e) => throw WriteQueryException("Can not insert model into database $e"));
      return id;
    }

    return null;
  }

  /// Delete an instance from the database
  Future<void> sqlDelete({final String? where, bool verbose = false}) async {
    _checkDbIsReady();
    var _where = where;
    if (where == null) {
      assert(id != null, "The instance id must not be null if no where clause is used");
      _where = "id=$id";
    }
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      await _db
          .delete(table: _table.name, where: _where, verbose: verbose)
          .catchError((final dynamic e) => throw WriteQueryException("Can not delete model from database $e"));
    }
  }

  /// Count rows
  Future<int?> sqlCount({final String? where, bool verbose = false}) async {
    final _db = db;
    final _table = table;
    if (_db != null && _table != null) {
      final n = _db
          .count(table: _table.name, where: where, verbose: verbose)
          .catchError((final dynamic e) => throw ReadQueryException("Can not count from database $e"));
      return n;
    }
    return null;
  }

  Map<String, String?> _toStringsMap(final Map<String, dynamic> map) {
    final res = <String, String?>{};
    map.forEach((final String k, final dynamic v) {
      if (v == null) {
        res[k] = null;
      } else {
        res[k] = "$v";
      }
    });
    return res;
  }

  void _checkDbIsReady() {
    assert(table != null);
    assert(db != null);
    assert(db!.isReady, "Please initialize the database by running db.init()");
  }
}

class _EncodedFk {
  const _EncodedFk({required this.table, required this.name, required this.encodedName, required this.refColName});

  final DbTable table;
  final String name;
  final String encodedName;
  final String refColName;

  @override
  String toString() {
    final s = StringBuffer()
      ..write("Encoded fk:")
      ..write("\n- Table: $table")
      ..write("\n- Name: $name")
      ..write("\n- Encoded name: $encodedName")
      ..write("\n- Ref col name: $refColName");
    return s.toString();
  }
}
