import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlcool/src/database.dart';

class SelectBloc {
  SelectBloc(this.table,
      {int offset: 0,
      int limit: 10,
      String where: "",
      String select,
      String joinTable,
      String joinOn}) {
    this.offset = offset;
    this.limit = limit;
    this.where = where;
    this.select = select;
    this.joinTable = joinTable;
    this.joinOn = joinOn;
    this._getItems();
  }

  final String table;
  int offset;
  int limit;
  String where;
  String select;
  String joinTable;
  String joinOn;

  final _itemController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  _getItems() async {
    List<Map<String, dynamic>> res;
    if (joinTable == null) {
      res = await db.select(table, offset: offset, limit: limit, where: where);
    } else {
      res = await db.join(table, select, joinTable, joinOn,
          offset: offset, limit: limit, where: where);
    }
    _itemController.sink.add(res);
  }

  StreamBuilder listStreamBuilder(Function getListTile) {
    return StreamBuilder<dynamic>(
      stream: this.items,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              var item = snapshot.data[index];
              return getListTile(item);
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
