import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:observable/observable.dart';
import 'package:sqlcool/sqlcool.dart';
import '../conf.dart';

class _SyncMapPageState extends State<SyncMapPage> {
  SynchronizedMap productPrice;
  SelectBloc bloc;

  void setInitialData() async {
    // get initial product price
    num initialPrice;
    try {
      var res =
          await db.select(table: "product", columns: "price", where: "id=1");
      initialPrice = res[0]["price"];
    } catch (e) {
      throw (e);
    }
    // set the initial synchronized map data
    productPrice = SynchronizedMap(
        db: db,
        table: "product",
        where: "id=1",
        data: ObservableMap.from({"price": "$initialPrice"}),
        verbose: true);
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
        limit: 1,
        reactive: true);
    setInitialData();
    super.initState();
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
              return const CircularProgressIndicator();
            }
          }),
      Positioned(
          bottom: 30.0,
          left: 30.0,
          child: RaisedButton(
              child: const Text("Change price"),
              onPressed: () => changePrice())),
    ]));
  }
}

class SyncMapPage extends StatefulWidget {
  @override
  _SyncMapPageState createState() => _SyncMapPageState();
}
