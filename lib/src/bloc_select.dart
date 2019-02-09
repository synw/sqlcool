import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database.dart';

class SelectBloc {
  SelectBloc(
      {@required this.table,
      this.database,
      this.offset,
      this.limit,
      this.where,
      this.columns: "*",
      this.joinTable,
      this.joinOn,
      this.orderBy,
      this.verbose})
      : assert(table != null) {
    (database == null) ? database = db : database = database;
    this._getItems();
  }

  Db database;
  final String table;
  int offset;
  int limit;
  String orderBy;
  String columns;
  String where;
  String joinTable;
  String joinOn;
  bool verbose;

  final _itemController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  _getItems() async {
    List<Map<String, dynamic>> res;
    if (joinTable == null) {
      try {
        res = await database.select(
            table: table,
            columns: columns,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose);
      } catch (e) {
        _itemController.sink.addError(e);
        return;
      }
    } else {
      try {
        res = await database.join(
            table: table,
            columns: columns,
            joinTable: joinTable,
            joinOn: joinOn,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose);
      } catch (e) {
        _itemController.sink.addError(e);
        return;
      }
    }
    _itemController.sink.add(res);
  }
}
