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
            body: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: <Widget>[
                    ExampleTile(
                      title: "Select bloc",
                      iconData: Icons.select_all,
                      route: "/select_bloc",
                    ),
                    ExampleTile(
                      title: "Upsert",
                      iconData: Icons.system_update_alt,
                      route: "/upsert",
                    ),
                    ExampleTile(
                      title: "Join query",
                      iconData: Icons.view_module,
                      route: "/join",
                    ),
                    ExampleTile(
                      title: "Db model",
                      iconData: Icons.content_paste,
                      route: "/dbmodel",
                    ),
                  ],
                )));
  }
}

class PageIndex extends StatefulWidget {
  @override
  _PageIndexState createState() => _PageIndexState();
}

class ExampleTile extends StatelessWidget {
  ExampleTile(
      {@required this.iconData, @required this.title, @required this.route});

  final IconData iconData;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(children: <Widget>[
        Icon(iconData, size: 65.0, color: Colors.grey),
        Padding(padding: const EdgeInsets.all(5.0), child: Text(title)),
      ]),
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }
}
