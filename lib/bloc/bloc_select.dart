import 'dart:async';
import 'package:sqlcool/sqlcool.dart';

class SelectBloc {
  SelectBloc(this.table, {offset: 0, limit: 10, where: ""}) {
    this.offset = offset;
    this.limit = limit;
    this.where = where;
    this.getItems();
  }

  final String table;
  int offset;
  int limit;
  String where;

  final _itemController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  getItems() async {
    List<Map<String, dynamic>> res =
        await db.select(table, offset: offset, limit: limit, where: where);
    _itemController.sink.add(res);
  }
}
