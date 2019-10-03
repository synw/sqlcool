import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import 'table.dart';
import '../appbar.dart';

class _DbViewerState extends State<DbViewer> {
  _DbViewerState({@required this.db});

  final Db db;

  Map<DbTable, int> _tableNumRows;
  var _ready = false;

  Future<Map<DbTable, int>> countRows() async {
    await db.onReady;
    final tnr = <DbTable, int>{};
    for (final table in db.schema.tables) {
      print("NR COUNT ${table.name}");
      final v = await db.count(table: table.name);
      tnr[table] = v;
    }
    print("NR $tnr");
    return tnr;
  }

  @override
  void initState() {
    super.initState();
    countRows().then((tnr) => setState(() {
          _tableNumRows = tnr;
          _ready = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    final rows = <Widget>[];
    _tableNumRows.forEach((table, n) => rows.add(GestureDetector(
            child: ListTile(
          title: Text("${table.name}"),
          trailing: Text("$n rows"),
          onTap: () => Navigator.of(context).push<DbViewerTable>(
              MaterialPageRoute(builder: (BuildContext context) {
            return DbViewerTable(db: db, table: table);
          })),
        ))));
    return Scaffold(
        appBar: appBar(context, title: "Tables"),
        body: ListView(children: rows));
  }
}

class DbViewer extends StatefulWidget {
  DbViewer({@required this.db})
      : assert(db.hasSchema,
            "The database has no schema, the viewer is unavailable");

  final Db db;

  @override
  _DbViewerState createState() => _DbViewerState(db: db);
}
