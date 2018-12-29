import 'dart:async';
import 'package:sqlcool/src/database.dart';

class SelectBloc {
  SelectBloc(this.table, {int offset: 0, int limit: 10, String where: ""}) {
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
