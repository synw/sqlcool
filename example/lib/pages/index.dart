import 'package:flutter/material.dart';

class PageIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              child: Text("Select bloc"),
              onPressed: () => Navigator.of(context).pushNamed("/select_bloc"),
            ),
            RaisedButton(
              child: Text("Join query"),
              onPressed: () => Navigator.of(context).pushNamed("/join"),
            ),
          ],
        ));
  }
}
