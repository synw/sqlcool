import 'dart:async';
import 'package:sqlcool/src/database.dart';

class SelectBloc {
  SelectBloc(
      {this.table,
      this.offset,
      this.limit,
      this.where,
      this.columns: "*",
      this.joinTable,
      this.joinOn,
      this.orderBy,
      this.verbose}) {
    this._getItems();
  }

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
      res = await db.select(
          table: table,
          columns: columns,
          offset: offset,
          limit: limit,
          where: where,
          orderBy: orderBy,
          verbose: verbose);
    } else {
      res = await db.join(
          table: table,
          columns: columns,
          joinTable: joinTable,
          joinOn: joinOn,
          offset: offset,
          limit: limit,
          where: where,
          orderBy: orderBy,
          verbose: verbose);
    }
    _itemController.sink.add(res);
  }
}
