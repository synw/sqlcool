import 'package:flutter/foundation.dart';
import 'package:sqlcool/src/exceptions.dart';

import '../../database.dart';
import 'column.dart';
import 'table.dart';

/// The database model class to extend
class DbModel {
  /// The database id of the model instance
  ///
  /// **Important** : it must be overriden
  int id;

  /// get the database
  Db get db => null;

  /// get the table schema
  DbTable get table => null;

  /// The database row serializer for the model
  ///
  /// **Important** : it must be overriden
  Map<String, dynamic> toDb() => <String, dynamic>{};

  /// The database row deserializer for the model
  ///
  /// **Important** : it must be overriden
  DbModel fromDb(Map<String, dynamic> map) => null;

  /// Select rows in the database table with joins on foreign keys
  Future<List<dynamic>> sqlJoin(
      {int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    print("> Sqljoin for table $table");
    //table.describe();
    final _joinTables = <String>[];
    final _joinOn = <String>[];
    final _select = <String>[];
    final _encodedFks = <_EncodedFk>[];
    if (!table.hasColumn("id")) {
      table.columns.add(const DbColumn(name: "id", type: DbColumnType.integer));
    }
    table.columns.forEach((c) {
      if (!c.isForeignKey) {
        _select.add("${table.name}.${c.name} AS ${c.name}");
      }
    });
    for (final fkCol in table.foreignKeys) {
      final fkTable = db.schema.table(fkCol.reference);
      _joinTables.add(fkTable.name);
      //print("FK COLS $fkTable: ${fkTable.columns}");
      final c = fkTable.columns;
      if (!fkTable.hasColumn("id")) {
        c.add(const DbColumn(name: "id", type: DbColumnType.integer));
      }
      //print("NEW FK COLS ${fkTable.columns}");
      _joinOn.add("${table.name}.${fkCol.name}=${fkTable.name}.id");
      //print("Joins add ${table.name}.${fkCol.name}=${fkTable.name}.id");
      for (final _fkTableCol in c) {
        final encodedName = "${fkTable.name}_${_fkTableCol.name}";
        final fk = _EncodedFk(
            table: fkTable,
            name: _fkTableCol.name,
            encodedName: encodedName,
            refColName: fkCol.name);
        _encodedFks.add(fk);
        final encodedFkName = "${fkTable.name}.${fk.name} AS $encodedName";
        _select.add(encodedFkName);
      }
    }
    final columns = _select.join(",");
    final res = await db.mJoin(
        table: table.name,
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
    for (final row in res) {
      final endRow = <String, dynamic>{};
      final fkData = <String, Map<String, dynamic>>{};
      row.forEach((key, dynamic value) {
        final encodedFk =
            _encodedFks.where((element) => element.encodedName == key).toList();
        if (encodedFk.isEmpty) {
          // it is not a foreign key
          endRow[key] = value;
        } else {
          final efk = encodedFk[0];
          //print("EFK $efk");
          if (!fkData.containsKey(efk.refColName)) {
            fkData[efk.refColName] = <String, dynamic>{};
          }
          fkData[efk.refColName][efk.name] = value;
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
    //print("QUERY END RES: $endRes");
    final endModelData = <dynamic>[];
    for (final r in endRes) {
      endModelData.add(fromDb(r));
    }
    //print("End model data: $endModelData");
    return endModelData;
  }

  /// Select rows in the database table
  Future<List<dynamic>> sqlSelect(
      {String where,
      String orderBy,
      int limit,
      int offset,
      String groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    // do not take the foreign keys
    final cols = <String>["id"];
    for (final col in table.columns) {
      if (!col.isForeignKey) {
        cols.add(col.name);
      }
    }
    final columns = cols.join(",");
    final res = await db.select(
        table: table.name,
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

  /// Update a row in the database table
  Future<void> sqlUpdate({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await db
        .update(table: table.name, row: row, where: 'id=$id', verbose: verbose)
        .catchError((dynamic e) =>
            throw WriteQueryException("Can not update model into database $e"));
  }

  /// Upsert a row in the database table
  Future<void> sqlUpsert(
      {bool verbose = false,
      String indexColumn,
      List<String> preserveColumns = const <String>[]}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await db
        .upsert(
            table: table.name,
            row: row,
            indexColumn: indexColumn,
            preserveColumns: preserveColumns,
            verbose: verbose)
        .catchError((dynamic e) =>
            throw WriteQueryException("Can not upsert model into database $e"));
  }

  /// Insert a row in the database table
  Future<int> sqlInsert({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final id = await db
        .insert(table: table.name, row: row, verbose: verbose)
        .catchError((dynamic e) =>
            throw WriteQueryException("Can not insert model into database $e"));
    return id;
  }

  /// Insert a row in the database table if it does not exist already
  @Deprecated(
      "The insertIfNotExists function will be removed after version 4.4.0")
  Future<int> sqlInsertIfNotExists({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final id = await db
        .insertIfNotExists(table: table.name, row: row, verbose: verbose)
        .catchError((dynamic e) =>
            throw WriteQueryException("Can not insert model into database $e"));
    return id;
  }

  /// Delete an instance from the database
  Future<void> sqlDelete({String where, bool verbose = false}) async {
    _checkDbIsReady();
    var _where = where;
    if (where == null) {
      assert(id != null,
          "The instance id must not be null if no where clause is used");
      _where = "id=$id";
    }
    await db
        .delete(table: table.name, where: _where, verbose: verbose)
        .catchError((dynamic e) =>
            throw WriteQueryException("Can not delete model from database $e"));
  }

  /// Count rows
  Future<int> sqlCount({String where, bool verbose = false}) async {
    final n = db
        .count(table: table.name, where: where, verbose: verbose)
        .catchError((dynamic e) =>
            throw ReadQueryException("Can not count from database $e"));
    return n;
  }

  Map<String, String> _toStringsMap(Map<String, dynamic> map) {
    final res = <String, String>{};
    map.forEach((String k, dynamic v) => res[k] = "$v");
    return res;
  }

  void _checkDbIsReady() {
    assert(table != null);
    assert(db != null);
    assert(db.isReady, "Please initialize the database by running db.init()");
  }
}

class _EncodedFk {
  const _EncodedFk(
      {@required this.table,
      @required this.name,
      @required this.encodedName,
      @required this.refColName});

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
