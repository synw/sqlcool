import 'package:flutter/material.dart';
import '../conf.dart';

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
        ? Scaffold(body: Center(child: Text("The datase is initializing ...")))
        : Container(
            color: Colors.lightBlue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  child: Text("Select bloc"),
                  onPressed: () =>
                      Navigator.of(context).pushNamed("/select_bloc"),
                ),
                RaisedButton(
                  child: Text("Join query"),
                  onPressed: () => Navigator.of(context).pushNamed("/join"),
                ),
              ],
            ));
  }
}

class PageIndex extends StatefulWidget {
  @override
  _PageIndexState createState() => _PageIndexState();
}
