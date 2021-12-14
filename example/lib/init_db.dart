import 'package:flutter/material.dart';
import 'package:sqlcool2/sqlcool2.dart';
import 'dbmodels/schema.dart';

Future<void> initDb(
    {@required SqlDb db,
    String path = "items2.sqlite",
    bool absPath = false}) async {
  // define the tables
  final category = DbTable("category")..varchar("name", unique: true);
  final product = DbTable("product")
    ..varchar("name", unique: true)
    ..integer("price")
    ..foreignKey("category", onDelete: OnDelete.cascade)
    ..index("name");
  // prepare the queries
  final populateQueries = <String>[
    'INSERT INTO category(name) VALUES("Category 1")',
    'INSERT INTO category(name) VALUES("Category 2")',
    'INSERT INTO category(name) VALUES("Category 3")',
    'INSERT INTO product(name,price,category) VALUES("Product 1", 50, 1)',
    'INSERT INTO product(name,price,category) VALUES("Product 2", 30, 1)',
    'INSERT INTO product(name,price,category) VALUES("Product 3", 20, 2)'
  ];
  // initialize the database
  await db
      .init(
          path: path,
          schema: [
            category, product,
            // db models
            manufacturerTable,
            carTable,
          ],
          queries: populateQueries,
          absolutePath: absPath,
          verbose: true)
      .catchError((dynamic e) {
    throw Exception("Error initializing the database: ${e.message}");
  });
  print("Database initialized with schema:");
  //db.schema.describe();
  print("SCHEMA TABLES ${db.schema.tables}");
  final q = await db.query(
      "SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%';");
  print("T $q");
}

Future<void> initDb2(
    {@required Db db,
    String path = "items.sqlite",
    bool absPath = false}) async {
  // define the tables
  final category = DbTable("category")..varchar("name", unique: true);
  final product = DbTable("product")
    ..varchar("name", unique: true)
    ..integer("price")
    ..foreignKey("category", onDelete: OnDelete.cascade)
    ..index("name");
  // prepare the queries
  final populateQueries = <String>[
    'INSERT INTO category(name) VALUES("Category 1")',
    'INSERT INTO category(name) VALUES("Category 2")',
    'INSERT INTO category(name) VALUES("Category 3")',
    'INSERT INTO product(name,price,category) VALUES("Product 1", 50, 1)',
    'INSERT INTO product(name,price,category) VALUES("Product 2", 30, 1)',
    'INSERT INTO product(name,price,category) VALUES("Product 3", 20, 2)'
  ];
  // initialize the database
  await db
      .init(
          path: path,
          schema: [
            category,
            product,
            // db models
            manufacturerTable,
            carTable,
          ],
          queries: populateQueries,
          absolutePath: absPath,
          verbose: true)
      .catchError((dynamic e) {
    throw ("Error initializing the database: ${e.message}");
  });
  //print("Database initialized with schema:");
  //db.schema.describe();
}
