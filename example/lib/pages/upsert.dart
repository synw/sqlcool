import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import '../conf.dart';

class _UpsertPageState extends State<UpsertPage> {
  SelectBloc bloc;
  int numProducts;

  final r = Random();

  @override
  void initState() {
    bloc = SelectBloc(
        database: db,
        table: "product",
        columns: "name,price",
        orderBy: 'name ASC',
        reactive: true);
    db.count(table: "product").then((n) => numProducts = n);
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  void upsertAdd() async {
    final price = r.nextInt(100);
    await db.upsert(
        table: "product",
        row: {
          "name": "Product ${numProducts + 1}",
          "price": "$price",
          "category": "1"
        },
        verbose: true);
    await db.count(table: "product").then((n) => numProducts = n);
  }

  void upsertUpdate() async {
    final n = r.nextInt(100);
    await db.upsert(
        table: "product",
        row: {"name": "Product 1", "price": "$n"},
        preserveColumns: ["category"],
        indexColumn: "name",
        verbose: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upsert")),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Add"),
                onPressed: upsertAdd,
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              RaisedButton(
                child: Text("Update"),
                onPressed: upsertUpdate,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: bloc.items,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = snapshot.data[index];
                      return ListTile(
                        title: Text(item["name"].toString()),
                        trailing: Text("${item["price"]}"),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class UpsertPage extends StatefulWidget {
  @override
  _UpsertPageState createState() => _UpsertPageState();
}
