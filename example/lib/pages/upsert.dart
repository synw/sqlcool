import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import '../conf.dart';

class _UpsertPageState extends State<UpsertPage> {
  SqlSelectBloc bloc;
  int numProducts;

  final Random r = Random();

  @override
  void initState() {
    bloc = SqlSelectBloc(
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

  Future<void> upsertAdd() async {
    final price = r.nextInt(100);
    await db.upsert(
        table: "product",
        row: DbRow(<DbRecord<dynamic>>[
          DbRecord<String>("name", "Product ${numProducts + 1}"),
          DbRecord<int>("price", price),
          DbRecord<int>("category", 1)
        ]),
        verbose: true);
    await db.count(table: "product").then((n) => numProducts = n);
  }

  Future<void> upsertUpdate() async {
    final n = r.nextInt(100);
    await db.upsert(
        table: "product",
        row: DbRow(<DbRecord<dynamic>>[
          DbRecord<String>("name", "Product 1"),
          DbRecord<int>("price", n),
          DbRecord<int>("category", 1)
        ]),
        preserveColumns: ["category"],
        indexColumn: "name",
        verbose: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upsert")),
      body: Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: const Text("Add"),
                onPressed: upsertAdd,
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              RaisedButton(
                child: const Text("Update"),
                onPressed: upsertUpdate,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: bloc.rows,
              builder:
                  (BuildContext context, AsyncSnapshot<List<DbRow>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final row = snapshot.data[index];
                      return ListTile(
                        title: Text(row.record<String>("name")),
                        trailing: Text("${row.record<int>("price")}"),
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
