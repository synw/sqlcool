import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database.dart';

/// A ready to use select bloc
///
/// Provides a stream with the rows corresponding to the query. This
/// stream, accssible via [items], will send new data if something changes
/// in the database if the [reactive] parameter is true
///
/// Join queries are possible.
class SelectBloc {
  /// Create a select bloc with the specified options. The select
  /// bloc will fire a query on creation
  SelectBloc(
      {@required this.table,
      @required this.database,
      this.offset,
      this.limit,
      this.where,
      this.columns = "*",
      this.joinTable,
      this.joinOn,
      this.orderBy,
      this.reactive = false,
      this.verbose = false})
      : assert(database != null),
        assert(table != null),
        assert(database.isReady) {
    _getItems();
    if (reactive) {
      _changefeed = database.changefeed.listen((change) {
        _getItems();
        if (verbose) {
          print("CHANGE IN THE DATABASE: $change");
        }
      });
    }
  }

  /// The database
  final Db database;

  /// The table name
  final String table;

  /// Offset sql statement
  int offset;

  /// Limit sql statement
  int limit;

  /// Order by sql statement
  String orderBy;

  /// Select sql statement
  String columns;

  /// Where sql statement
  String where;

  /// The join sql statement
  String joinTable;

  /// The on sql statement
  String joinOn;

  /// The reactivity of the bloc. Will send new values in [items]
  /// when something changes in the database if set to true
  bool reactive;

  /// The verbosity
  bool verbose;

  StreamSubscription _changefeed;
  final _itemController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  bool _changefeedIsActive = true;

  /// A stream of rows returned by the query. Will return new items
  /// if something changes in the database when the [reactive] parameter
  /// is true
  Stream<List<Map<String, dynamic>>> get items => _itemController.stream;

  /// A convenience method to update the bloc items if needed
  /// by adding to the sink
  void update(List<Map<String, dynamic>> _items) {
    _itemController.sink.add(_items);
  }

  /// Cancel the changefeed subscription
  void dispose() {
    _itemController.close();
    if (reactive) {
      _changefeed.cancel();
      _changefeedIsActive = false;
    }
  }

  Future<void> _getItems() async {
    List<Map<String, dynamic>> res;
    if (joinTable == null) {
      try {
        res = await database.select(
            table: table,
            columns: columns,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose);
      } catch (e) {
        if (_changefeedIsActive) {
          _itemController.sink.addError(e);
        } else {
          throw (e);
        }
        return;
      }
    } else {
      try {
        res = await database.join(
            table: table,
            columns: columns,
            joinTable: joinTable,
            joinOn: joinOn,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose);
      } catch (e) {
        if (_changefeedIsActive) {
          _itemController.sink.addError(e);
        } else {
          throw (e);
        }
        return;
      }
    }
    if (_changefeedIsActive) _itemController.sink.add(res);
  }
}
