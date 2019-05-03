import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';
import '../conf.dart';

class _SyncMapPageState extends State<SyncMapPage> {
  SynchronizedMap productPrice;
  SelectBloc bloc;
  bool ready = false;

  Future<void> setMap() async {
    productPrice = SynchronizedMap(
        db: db,
        table: "product",
        where: 'name="Product 1"',
        columns: "price",
        verbose: true);
    await productPrice.onReady;
  }

  Future<void> changePrice() async {
    int _newPrice = Random().nextInt(100);
    // this will update the price in the database
    productPrice.data["price"] = "$_newPrice";
  }

  @override
  void initState() {
    this.bloc = SelectBloc(
        database: db,
        table: "product",
        orderBy: "id",
        where: 'name="Product 1"',
        reactive: true);
    setMap().then((_) => setState(() => ready = true));
    super.initState();
  }

  @override
  void dispose() {
    productPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      StreamBuilder<List<Map>>(
          stream: bloc.items,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: int.parse("${snapshot.data.length}"),
                  itemBuilder: (BuildContext context, int index) {
                    dynamic item = snapshot.data[index];
                    return ListTile(
                        title: Text("Price ${item["price"]}",
                            textScaleFactor: 1.5));
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      ready
          ? Positioned(
              bottom: 30.0,
              left: 30.0,
              child: RaisedButton(
                  child: const Text("Change price"),
                  onPressed: () => changePrice()))
          : const Text(""),
    ]));
  }
}

class SyncMapPage extends StatefulWidget {
  @override
  _SyncMapPageState createState() => _SyncMapPageState();
}
