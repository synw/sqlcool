import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqlcool2/sqlcool2.dart';
import '../conf.dart';

class _PageJoinQueryState extends State<PageJoinQuery> {
  final _streamController = StreamController<List<DbRow>>();

  @override
  void initState() {
    db
        .join(
      table: "product",
      columns: "product.name, price, category.name as category_name",
      joinTable: "category",
      joinOn: "product.category = category.id",
      verbose: true,
    )
        .then((items) {
      _streamController.sink.add(items);
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join query")),
      body: StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List<DbRow>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                final row = snapshot.data[index];
                final price = row.record<int>("price");
                return ListTile(
                  title: Text(row.record<String>("name")),
                  subtitle: Text(row.record<String>("category_name")),
                  trailing: (price != null) ? Text("$price") : const Text(""),
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class PageJoinQuery extends StatefulWidget {
  @override
  _PageJoinQueryState createState() => _PageJoinQueryState();
}
