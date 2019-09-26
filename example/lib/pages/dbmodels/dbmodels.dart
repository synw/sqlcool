import 'package:flutter/material.dart';
import 'model.dart';
import 'conf.dart';

class _DbModelPageState extends State<DbModelPage> {
  var data = <DataModel>[];

  DataModel _dm;

  Future<void> generateDataPoints() async {
    var i = 1;
    while (i < 11) {
      final dataPoint = DataModel(
          stringVal: "Datapoint $i",
          intVal: i,
          doubleVal: i.toDouble(),
          boolVal: true);
      await dataPoint.sqlInsert(verbose: true);
      data.add(dataPoint);
      ++i;
    }
    print("Inserted ${i - 1} datapoints");
  }

  Future<void> initModel() async {
    // make sure the table is initialized
    await initDbModelConf();
    // create and save some data
    await generateDataPoints();
    // query the database for initial data
    await selectData();
  }

  Future<void> selectData() async {
    /// select all the [DataModel] rows in the database
    data = List<DataModel>.from(await _dm.sqlSelect(verbose: true));
    // or we use our custom method
    // data = await _dm.selectAll();
  }

  @override
  void initState() {
    _dm = DataModel.empty();
    initModel().then((_) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i) {
          final dataPoint = data[i];
          return ListTile(
            title: Text("${dataPoint.stringVal}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await dataPoint.sqlDelete();
                // refresh
                await selectData();
                setState(() {});
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
