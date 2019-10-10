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
}

/// The database model class to extend
class DbModel {
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

  /// Select rows in the database table with joins on foreign keys
  Future<List<dynamic>> sqlJoin(
      {int offset,
      int limit,
      String orderBy,
      String where,
      String groupBy,
      bool verbose = false}) async {
    _checkDbIsReady();
    final colStringsSelect = <String>["${dbTable.table.name}.id AS id"];
    // get regular column names
    for (final col in dbTable.table.columns) {
      if (!col.isForeignKey) {
        final encodedName = "${dbTable.table.name}.${col.name} AS ${col.name}";
        colStringsSelect.add(encodedName);
      }
    }
    // build up the joins from schema
    final joinsTables = <String>[];
    final joinsOn = <String>[];
    final fkColStringsSelect = <String>[];
    final fkPropertiesCols = <String, Map<String, String>>{};
    for (final fkCol in dbTable.table.foreignKeys) {
      joinsTables.add(fkCol.name);
      joinsOn.add("${dbTable.table.name}.${fkCol.name}=${fkCol.name}.id");
      // grab the foreign key table schema
      final fkTable = dbTable.db.schema.table(fkCol.name);
      // get columns for foreign key
      for (final fc in fkTable.columns) {
        // encode for select
        final endName = "${fkCol.name}_${fc.name}";
        final encodedFkName = "${fkCol.name}.${fc.name} AS $endName";
        fkColStringsSelect.add(encodedFkName);
        fkPropertiesCols[endName] = <String, String>{
          "col_name": fc.name,
          "fk_name": fkCol.name
        };
      }
    }
    colStringsSelect.addAll(fkColStringsSelect);
    final columns = colStringsSelect.join(",");
    final res = await dbTable.db.mJoin(
        table: dbTable.table.name,
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
    //print("Q RES $res");
    //print("FK COL PROPS $fkPropertiesCols / ");
    final fres = <Map<String, dynamic>>[];
    for (final row in res) {
      final newRow = <String, dynamic>{};
      final fkData = <String, Map<String, dynamic>>{};
      // set fk data keys
      for (final c in dbTable.table.foreignKeys) {
        fkData[c.name] = <String, dynamic>{};
      }
      // retrieve data
      row.forEach((String k, dynamic v) {
        //print("FK COL STR $k");
        if (fkPropertiesCols.keys.contains(k)) {
          //print("VALUE $v");
          fkData[fkPropertiesCols[k]["fk_name"]]
              [fkPropertiesCols[k]["col_name"]] = v;
          // decode foreign key name from select results
          newRow[fkPropertiesCols[k]["fk_name"]] =
              fkData[fkPropertiesCols[k]["fk_name"]];
          print("ROW $newRow");
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
    for (final col in dbTable.table.columns) {
      if (!col.isForeignKey) {
        cols.add(col.name);
      }
    }
    final columns = cols.join(",");
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

  /// Update a row in the database table
  Future<void> sqlUpdate({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    await dbTable.db
        .update(
            table: dbTable.table.name,
            row: row,
            where: 'id=$id',
            verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not update model into database $e"));
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
  Future<int> sqlInsert({bool verbose = false}) async {
    _checkDbIsReady();
    final data = this.toDb();
    final row = _toStringsMap(data);
    final id = await dbTable.db
        .insert(table: dbTable.table.name, row: row, verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not insert model into database $e"));
    return id;
  }

  /// Delete an instance from the database
  Future<void> sqlDelete({String where, bool verbose = false}) async {
    _checkDbIsReady();
    if (where == null) {
      assert(id != null,
          "The instance id must not be null if no where clause is used");
      where = "id=$id";
    }
    await dbTable.db
        .delete(table: dbTable.table.name, where: where, verbose: verbose)
        .catchError(
            (dynamic e) => throw ("Can not delete model from database $e"));
  }

  /// Count rows
  Future<int> sqlCount({String where, bool verbose = false}) async {
    final n = dbTable.db
        .count(table: dbTable.table.name, where: where, verbose: verbose)
        .catchError((dynamic e) => throw ("Can not count from database $e"));
    return n;
  }

  Map<String, String> _toStringsMap(Map<String, dynamic> map) {
    final res = <String, String>{};
    map.forEach((String k, dynamic v) => res[k] = "$v");
    return res;
  }

  void _checkDbIsReady() {
    assert(dbTable != null);
    assert(dbTable.db != null);
    assert(dbTable.db.isReady,
        "Please intialize the database by running db.init()");
  }
}
