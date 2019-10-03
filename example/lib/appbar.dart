import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, {String title = "Sqlcool example"}) {
  return AppBar(
    title: Text(title),
    actions: <Widget>[
      IconButton(
        tooltip: "View the database",
        icon: Icon(Icons.view_list),
        onPressed: () => Navigator.of(context).pushNamed("/dbmanager"),
      )
    ],
  );
}
