import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqlcool2/sqlcool2.dart';

import '../conf.dart';
import '../dialogs.dart';

class _PageSelectBlocState extends State<PageSelectBloc> {
  SqlSelectBloc bloc;
  StreamSubscription _changefeed;

  @override
  void initState() {
    // declare the query
    this.bloc = SqlSelectBloc(
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
      appBar: AppBar(title: const Text("Select bloc")),
      body: StreamBuilder<List<DbRow>>(
          stream: bloc.rows,
          builder: (BuildContext context, AsyncSnapshot<List<DbRow>> snapshot) {
            if (snapshot.hasData) {
              // the select query has not found anything
              if (snapshot.data.isEmpty) {
                return const Center(
                  child: Text("No data. Use the + button to insert an item"),
                );
              }
              // the select query has results
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final row = snapshot.data[index];
                    final name = row.record<String>("name");
                    final id = row.record<int>("id");
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
