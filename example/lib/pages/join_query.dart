import 'dart:async';
import 'package:flutter/material.dart';
import '../conf.dart';

class _PageJoinQueryState extends State<PageJoinQuery> {
  final _streamController = StreamController<List<Map<String, dynamic>>>();

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
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                final item = snapshot.data[index];
                return ListTile(
                  title: Text("${item["name"]}"),
                  subtitle: Text("${item["category_name"]}"),
                  trailing: (item["price"] != null)
                      ? Text("${item["price"]}")
                      : const Text(""),
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
