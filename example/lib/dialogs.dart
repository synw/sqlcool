import 'package:flutter/material.dart';
import 'database.dart';

insertItemDialog(BuildContext context) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add an item"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text("Save"),
            onPressed: () {
              String txt = controller.text;
              saveItem(txt).catchError((e) {
                throw ("Can not save item ${e.message}");
              });
              Navigator.of(context).pop(true);
            },
          ),
        ],
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
      );
    },
  );
}

deleteItemDialog(BuildContext context, String itemName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete $itemName?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          RaisedButton(
            child: Text("Delete"),
            color: Colors.red,
            onPressed: () {
              deleteItem(itemName).catchError((e) {
                throw (e);
              });
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

updateItemDialog(BuildContext context, String itemName) {
  final controller = TextEditingController(text: itemName);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Update item"),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text("Save"),
            onPressed: () {
              String txt = controller.text;
              updateItem(itemName, txt).catchError((e) {
                throw ("Can not update category $e");
              });
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
