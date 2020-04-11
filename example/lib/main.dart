import 'package:flutter/material.dart';

import 'conf.dart';
import 'dbmodels/dbmodels.dart';
import 'dbviewer/dbviewer.dart';
import 'init_db.dart';
import 'pages/index.dart';
import 'pages/join.dart';
import 'pages/select_bloc.dart';
import 'pages/upsert.dart';

void main() {
  runApp(MyApp());

  /// initialize the database async. We will use the [onReady]
  /// callback later to react to the initialization completed event
  initDb(db: db);
  initDb2(db: db2);
}

final routes = {
  '/': (BuildContext context) => PageIndex(),
  '/select_bloc': (BuildContext context) => PageSelectBloc(),
  '/join': (BuildContext context) => PageJoinQuery(),
  '/upsert': (BuildContext context) => UpsertPage(),
  '/dbmodel': (BuildContext context) => DbModelPage(),
  '/dbmanager': (BuildContext context) => DbViewer(db: db),
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
