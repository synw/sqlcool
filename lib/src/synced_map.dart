import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:observable/observable.dart';
import 'database.dart';

/// The synchronized map class
class SynchronizedMap {
  /// Default constructor
  SynchronizedMap(
      {@required this.db,
      @required this.table,
      @required this.where,
      @required this.data,
      this.verbose = false}) {
    _runQueue();
    _sub = data.changes.listen((records) {
      List<ChangeRecord> _changes = records
          .where((r) => r is MapChangeRecord && !r.isInsert && !r.isRemove)
          .toList();
      if (_changes.isEmpty) return;
      Map<String, String> _data = data.map((dynamic k, dynamic v) =>
          MapEntry<String, String>(k.toString(), v.toString()));
      _changeFeed.sink.add(_data);
    });
  }

  Future<void> _runQueue() async {
    await for (var _data in _changeFeed.stream) {
      await _runQuery(_data);
    }
  }

  /// The map containing the data to synchronize
  ObservableMap data;

  /// The database to use
  Db db;

  /// The table where to update data
  final String table;

  /// The sql where clause
  final String where;

  /// Verbosity
  bool verbose;

  StreamSubscription _sub;
  final _changeFeed = StreamController<Map<String, String>>();
  bool _isLocked = false;

  /// Run the update query to sync the map in the database
  Future<void> _runQuery(Map<String, String> _data) async {
    if (_isLocked) throw ("The synchronized map query is locked");
    try {
      _isLocked = true;
      await db.update(table: table, where: where, row: _data, verbose: verbose);
      _isLocked = false;
    } catch (e) {
      throw (e);
    }
  }

  /// Use dispose when finished to avoid memory leaks
  void dispose() {
    _sub.cancel();
    _changeFeed.close();
  }
}
