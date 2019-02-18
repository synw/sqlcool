import 'package:flutter/material.dart';
import 'page_selectbloc.dart';
import 'page_index.dart';
import 'conf.dart';

void main() {
  // the database must be initialized
  initDb().then((_) {
    runApp(MyApp());
  });
}

initDb() async {
  String q1 = """CREATE TABLE product (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      category_id INTEGER,
      CONSTRAINT category_name
        FOREIGN KEY (category_id) 
        REFERENCES category(id) 
        ON DELETE CASCADE
      )""";
  String q2 = """CREATE TABLE category (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL
      )""";
  String dbpath = "items.sqlite";
  await db.init(path: dbpath, queries: [q1, q2], verbose: true).catchError((e) {
    throw ("Error initializing the database: ${e.message}");
  });
}

final routes = {
  '/': (BuildContext context) => PageIndex(),
  '/select_bloc': (BuildContext context) => PageSelectBloc(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sqlcool example',
      routes: routes,
    );
  }
}
