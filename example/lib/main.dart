import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import 'page_selectbloc.dart';

void main() {
  initDb().then((_) {
    runApp(MyApp());
  });
}

initDb() async {
  String q = """CREATE TABLE items (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
  )""";
  String dbpath = "items.sqlite";
  await db.init(path: dbpath, queries: [q], verbose: true).catchError((e) {
    throw ("Error initializing the database: ${e.message}");
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sqlcool example',
      home: PageSelectBloc(),
    );
  }
}
