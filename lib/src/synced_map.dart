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
      @required this.columns,
      this.verbose = false}) {
    _initMap().then((m) {
      data = m;
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
      _readyCompleter.complete();
    });
  }

  /// The map containing the data to synchronize
  ObservableMap data;

  /// The database to use
  Db db;

  /// The table where to update data
  final String table;

  /// The sql where clause
  final String where;

  /// The columns to use for the map
  final String columns;

  /// Verbosity
  bool verbose;

  /// The on ready callback: fired when the map
  /// is ready to operate
  Future<Null> get onReady => _readyCompleter.future;

  StreamSubscription _sub;
  final _changeFeed = StreamController<Map<String, String>>();
  bool _isLocked = false;
  final Completer<Null> _readyCompleter = Completer<Null>();

  /// Use dispose when finished to avoid memory leaks
  void dispose() {
    _sub.cancel();
    _changeFeed.close();
  }

  Future<ObservableMap<String, String>> _initMap() async {
    Map<String, String> m = {};
    try {
      List<Map<String, dynamic>> res =
          await db.select(table: table, where: where, columns: columns);
      if (res.isEmpty) throw ("Can not find map data");
      res[0].forEach((String k, dynamic v) {
        m[k] = v.toString();
      });
    } catch (e) {
      throw (e);
    }
    return ObservableMap.from(m);
  }

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

  Future<void> _runQueue() async {
    await for (var _data in _changeFeed.stream) {
      await _runQuery(_data);
    }
  }
}
