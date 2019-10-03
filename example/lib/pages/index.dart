import 'package:flutter/material.dart';
import '../conf.dart';
import '../appbar.dart';

class _PageIndexState extends State<PageIndex> {
  bool databaseIsReady = false;

  @override
  void initState() {
    db.onReady.then((_) {
      print("STATE: THE DATABASE IS READY");
      setState(() {
        databaseIsReady = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !databaseIsReady
        ? Scaffold(
            body: Center(child: const Text("The database is initializing ...")))
        : Scaffold(
            appBar: appBar(context),
            body: Container(
                color: Colors.lightBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      child: const Text("Select bloc"),
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/select_bloc"),
                    ),
                    RaisedButton(
                      child: const Text("Upsert"),
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/upsert"),
                    ),
                    RaisedButton(
                      child: const Text("Join query"),
                      onPressed: () => Navigator.of(context).pushNamed("/join"),
                    ),
                    RaisedButton(
                      child: const Text("Db model"),
                      onPressed: () =>
                          Navigator.of(context).pushNamed("/dbmodel"),
                    ),
                  ],
                )));
  }
}

class PageIndex extends StatefulWidget {
  @override
  _PageIndexState createState() => _PageIndexState();
}
