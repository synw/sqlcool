/*import 'package:flutter/material.dart';


ListTile listTile(dynamic item) {
  return ListTile(

  );
}

StreamBuilder slqListBuilder(ListTile tile) {
  return StreamBuilder<List<Map<String, String>>>(
        stream: this.bloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, String>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, String> item = snapshot.data[index];
                return ListTile(
                  title: Text(item.filename),
                  leading: item.icon,
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDeleteDialog(item);
                    },
                  ),
                  onTap: () {
                    String path;
                    if (path == "/") {
                      path = this.path + item.filename;
                    } else {
                      path = this.path + "/" + item.filename;
                    }
                    if (item.type == "folder") {
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => DataviewPage(path)));
                    }
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
}*/
