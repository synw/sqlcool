import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database.dart';

class SelectBloc {
  SelectBloc(
      {@required this.table,
      @required this.database,
      this.offset,
      this.limit,
      this.where,
      this.columns: "*",
      this.joinTable,
      this.joinOn,
      this.orderBy,
      this.reactive: false,
      this.verbose: false})
      : assert(database != null),
        assert(table != null),
        assert(database.isReady) {
    _getItems();
    if (reactive) {
      _changefeed = database.changefeed.listen((change) {
        _getItems();
        if (verbose) {
          print("CHANGE IN THE DATABASE: $change");
        }
      });
    }
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
  bool reactive;
  bool verbose;
  StreamSubscription _changefeed;

  final _itemController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  bool _changefeedIsActive = true;

  get items => _itemController.stream;

  dispose() {
    _itemController.close();
    if (reactive) {
      _changefeed.cancel();
      _changefeedIsActive = false;
    }
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
        if (_changefeedIsActive) {
          _itemController.sink.addError(e);
        } else {
          throw(e);
        }
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
        if (_changefeedIsActive) {
          _itemController.sink.addError(e);
        } else {
          throw(e);
        }
        return;
      }
    }
    if (_changefeedIsActive) _itemController.sink.add(res);
  }
}
