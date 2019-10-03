import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import '../appbar.dart';

class _DbViewerTableState extends State<DbViewerTable> {
  _DbViewerTableState({@required this.db, @required this.table});

  final Db db;
  final DbTable table;

  List<Map<String, dynamic>> _rows;
  var _ready = false;

  Future<void> _getData() async {
    _rows = await db.select(table: table.name, limit: 100).catchError(
        (dynamic e) => throw ("Can not select from table ${table.name}"));
  }

  @override
  void initState() {
    super.initState();
    _getData().then((_) => setState(() => _ready = true));
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? Scaffold(
            appBar: appBar(context, title: "Table ${table.name}"),
            body: ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (BuildContext context, int index) {
                final row = _rows[index];
                return ListTile(title: Text("$row"));
              },
            ))
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class DbViewerTable extends StatefulWidget {
  DbViewerTable({@required this.db, @required this.table});

  final Db db;
  final DbTable table;

  @override
  _DbViewerTableState createState() =>
      _DbViewerTableState(db: db, table: table);
}
