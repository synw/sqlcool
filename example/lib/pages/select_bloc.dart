import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import '../dialogs.dart';
import '../conf.dart';

class _PageSelectBlocState extends State<PageSelectBloc> {
  SelectBloc bloc;
  StreamSubscription _changefeed;

  @override
  void initState() {
    // declare the query
    this.bloc = SelectBloc(
        database: db, table: "product", orderBy: 'name ASC', reactive: true);
    // listen for changes in the database
    _changefeed = db.changefeed.listen((change) {
      print("CHANGE IN THE DATABASE:");
      print("Change type: ${change.type}");
      print("Number of items impacted: ${change.value}");
      print("Query: ${change.query}");
      if (change.type == DatabaseChange.update) {
        print("${change.value} items updated");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _changefeed.cancel();
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select bloc")),
      body: StreamBuilder<List<Map>>(
          stream: bloc.items,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // the select query has not found anything
              if (snapshot.data.length == 0) {
                return Center(
                  child:
                      const Text("No data. Use the + button to insert an item"),
                );
              }
              // the select query has results
              return ListView.builder(
                  itemCount: int.parse("${snapshot.data.length}"),
                  itemBuilder: (BuildContext context, int index) {
                    final dynamic item = snapshot.data[index];
                    final name = "${item["name"]}";
                    final id = int.parse("${item["id"]}");
                    return ListTile(
                      title: GestureDetector(
                        child: Text(name),
                        onTap: () => updateItemDialog(context, name),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.grey,
                        onPressed: () => deleteItemDialog(context, name, id),
                      ),
                    );
                  });
            } else {
              // the select query is still running
              return const CircularProgressIndicator();
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => insertItemDialog(context),
      ),
    );
  }
}

class PageSelectBloc extends StatefulWidget {
  @override
  _PageSelectBlocState createState() => _PageSelectBlocState();
}
