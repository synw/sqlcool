import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
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
  // define the tables
  DbTable category = DbTable("category")..varchar("name", unique: true);
  DbTable product = DbTable("product")
    ..varchar("name", unique: true)
    ..integer("price")
    ..foreignKey("category", onDelete: OnDelete.cascade)
    ..index("name");
  // prepare the queries
  List<String> populateQueries = <String>[
    'INSERT INTO category(name) VALUES("Category 1")',
    'INSERT INTO category(name) VALUES("Category 2")',
    'INSERT INTO category(name) VALUES("Category 3")',
    'INSERT INTO product(name,price,category_id) VALUES("Product 1", 50, 1)',
    'INSERT INTO product(name,price,category_id) VALUES("Product 2", 30, 1)',
    'INSERT INTO product(name,price,category_id) VALUES("Product 3", 20, 2)'
  ];
  // initialize the database
  String dbpath = "items.sqlite";
  await db
      .init(
          path: dbpath,
          schema: [category, product],
          queries: populateQueries,
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
