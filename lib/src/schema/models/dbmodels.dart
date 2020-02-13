import 'package:sqlcool/src/exceptions.dart';

import '../../database.dart';
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
    final colStringsSelect = <String>["${table.name}.id AS id"];
    // get regular column names
    for (final col in table.columns) {
      if (!col.isForeignKey) {
        final encodedName = "${table.name}.${col.name} AS ${col.name}";
        colStringsSelect.add(encodedName);
      }
    }
    // build up the joins from schema
    final joinsTables = <String>[];
    final joinsOn = <String>[];
    final fkColStringsSelect = <String>[];
    final fkPropertiesCols = <String, Map<String, String>>{};
    for (final fkCol in table.foreignKeys) {
      final refTable = fkCol?.reference ?? fkCol.name;
      joinsTables.add(refTable);
      joinsOn.add("${table.name}.${fkCol.name}=${refTable}.id");
      // grab the foreign key table schema
      final fkTable = db.schema.table(refTable);
      // get columns for foreign key
      final fkColsNames =
          fkTable.columns.map<String>((col) => col.name).toList()..add("id");
      //for (final fc in fkTable.columns) {
      for (final fc in fkColsNames) {
        // encode for select
        final endName = "${refTable}_$fc";
        final encodedFkName = "$refTable.$fc AS $endName";
        fkColStringsSelect.add(encodedFkName);
        fkPropertiesCols[endName] = <String, String>{
          "col_name": fc,
          "fk_name": fkCol.name
        };
        //print("Encoded fk ${fkPropertiesCols[endName]}");
      }
    }
    colStringsSelect.addAll(fkColStringsSelect);
    final columns = colStringsSelect.join(",");
    final res = await db.mJoin(
        table: table.name,
        joinsTables: joinsTables,
        joinsOn: joinsOn,
        columns: columns,
        offset: offset,
        limit: limit,
        where: where,
        groupBy: groupBy,
        verbose: verbose);
    // encode foreign keys results into dict for proper
    // decoding with client .fromDb methods
    final fres = <Map<String, dynamic>>[];
    for (final row in res) {
      final newRow = <String, dynamic>{};
      final fkData = <String, Map<String, dynamic>>{};
      // set fk data keys
      String refTable;
      for (final c in table.foreignKeys) {
        refTable = c?.reference ?? c.name;
        fkData[refTable] = <String, dynamic>{};
      }
      // retrieve data
      row.forEach((String k, dynamic v) {
        if (fkPropertiesCols.keys.contains(k)) {
          fkData[refTable][fkPropertiesCols[k]["col_name"]] = v;
          // decode foreign key name from select results
          newRow[fkPropertiesCols[k]["fk_name"]] = fkData[refTable];
        } else {
          newRow[k] = v;
        }
      });
      fres.add(newRow);
    }
    final endRes = <dynamic>[];
    for (final row in fres) {
      endRes.add(fromDb(row));
    }
    return endRes;
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
      List<String> preserveColumns = const <String>[]}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await db
        .upsert(
            table: table.name,
            row: row,
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
    assert(db.isReady, "Please intialize the database by running db.init()");
  }
}
