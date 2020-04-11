import 'package:flutter/material.dart';
import 'models/car.dart';
import 'db.dart';

class _DbModelPageState extends State<DbModelPage> {
  var cars = <Car>[];

  Future<List<Car>> initModel() async {
    // populate db if needed
    await populateDb();
    // perform a join query on the database for initial data
    final c = await Car.selectRelated();
    print("Found ${c.length} cars: $c");
    return c;
  }

  @override
  void initState() {
    super.initState();
    initModel().then((c) => setState(() => cars = c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Db models")),
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
                final c = await Car.selectRelated();
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
