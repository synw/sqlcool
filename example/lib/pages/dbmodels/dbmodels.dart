import 'package:flutter/material.dart';
import 'models.dart';
import 'conf.dart';
import '../../appbar.dart';

class _DbModelPageState extends State<DbModelPage> {
  var cars = <Car>[];

  Future<List<Car>> initModel() async {
    // populate db if needed
    await populateDb();
    // query the database for initial data
    final c = await Car.select();
    print("Found ${c.length} cars");
    return c;
  }

  @override
  void initState() {
    initModel().then((c) => setState(() => cars = c));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (BuildContext context, int i) {
          final car = cars[i];
          return ListTile(
            title: Text("${car.name}"),
            subtitle: Text("Manufacturer: ${car.manufacturer.name}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await car.sqlDelete(verbose: true);
                // refresh
                final c = await Car.select();
                setState(() => cars = c);
              },
            ),
          );
        },
      ),
    );
  }
}

class DbModelPage extends StatefulWidget {
  @override
  _DbModelPageState createState() => _DbModelPageState();
}
