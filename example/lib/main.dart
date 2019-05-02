import 'package:flutter/material.dart';
import 'pages/select_bloc.dart';
import 'pages/index.dart';
import 'pages/join_query.dart';
import 'pages/upsert.dart';
import 'pages/sync_map.dart';
import 'conf.dart';

void main() {
  /// initialize the database async. We will use the [onReady]
  /// callback later to react to the initialization completed event
  initDb();
  runApp(MyApp());
}

Future<void> initDb() async {
  /// these queries will run only once, after the Sqlite file creation
  String q1 = """CREATE TABLE product (
      id INTEGER PRIMARY KEY,
      name VARCHAR(60) NOT NULL,
      price REAL NOT NULL,
      category_id INTEGER NOT NULL,
      CONSTRAINT category
        FOREIGN KEY (category_id) 
        REFERENCES category(id) 
        ON DELETE CASCADE
      )""";
  String q2 = """CREATE TABLE category (
      id INTEGER PRIMARY KEY,
      name VARCHAR(60) NOT NULL
      )""";
  String q3 = 'CREATE UNIQUE INDEX idx_product_name ON product (name)';
  // populate the database
  String q4 = 'INSERT INTO category(name) VALUES("Category 1")';
  String q5 = 'INSERT INTO category(name) VALUES("Category 2")';
  String q6 = 'INSERT INTO category(name) VALUES("Category 3")';
  String q7 =
      'INSERT INTO product(name,price,category_id) VALUES("Product 1", 50, 1)';
  String q8 =
      'INSERT INTO product(name,price,category_id) VALUES("Product 2", 30, 1)';
  String q9 =
      'INSERT INTO product(name,price,category_id) VALUES("Product 3", 20, 2)';
  String dbpath = "items.sqlite";
  await db
      .init(
          path: dbpath,
          queries: [q1, q2, q3, q4, q5, q6, q7, q8, q9],
          verbose: true)
      .catchError((dynamic e) {
    throw ("Error initializing the database: ${e.message}");
  });
}

final routes = {
  '/': (BuildContext context) => PageIndex(),
  '/select_bloc': (BuildContext context) => PageSelectBloc(),
  '/join': (BuildContext context) => PageJoinQuery(),
  '/upsert': (BuildContext context) => UpsertPage(),
  '/sync_map': (BuildContext context) => SyncMapPage(),
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
