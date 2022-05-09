import 'dart:async';

import 'package:flutter/foundation.dart';

import 'safe_api.dart';
import 'schema/models/row.dart';

/// A ready to use select bloc
///
/// Provides a stream with the rows corresponding to the query. This
/// stream, accssible via [rows], will send new data if something changes
/// in the database if the [reactive] parameter is true
///
/// Join queries are possible.
class SqlSelectBloc {
  /// Create a select bloc with the specified options. The select
  /// bloc will fire a query on creation
  SqlSelectBloc(
      {required this.database,
      required this.table,
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
        assert(database.isReady) {
    _getItems();
    if (reactive) {
      _changefeed = database.changefeed.listen((change) {
        if (table != null && change.table == table) {
          _getItems();
        }
        if (verbose) {
          print("CHANGE IN THE DATABASE: $change");
        }
      });
    }
  }

  /// The database
  final SqlDb database;

  /// The table name
  final String table;

  /// Offset sql statement
  int? offset;

  /// Limit sql statement
  int? limit;

  /// Order by sql statement
  String? orderBy;

  /// Select sql statement
  String columns;

  /// Where sql statement
  String? where;

  /// The join sql statement
  String? joinTable;

  /// The on sql statement
  String? joinOn;

  /// The reactivity of the bloc. Will send new values in [items]
  /// when something changes in the database if set to true
  bool reactive;

  /// The verbosity
  bool verbose;

  late StreamSubscription _changefeed;
  final _rowsController = StreamController<List<DbRow>>.broadcast();
  bool _changefeedIsActive = true;

  /// A stream of rows returned by the query. Will return new items
  /// if something changes in the database when the [reactive] parameter
  /// is true
  Stream<List<DbRow>> get rows => _rowsController.stream;

  /// A convenience method to update the bloc items if needed
  /// by adding to the sink
  void update(List<DbRow> _rows) => _rowsController.sink.add(_rows);

  /// Cancel the changefeed subscription
  void dispose() {
    _rowsController.close();
    if (reactive) {
      _changefeed.cancel();
      _changefeedIsActive = false;
    }
  }

  Future<void> _getItems() async {
    final rows = <DbRow>[];
    try {
      if (joinTable != null) {
        rows.addAll(await database.join(
            table: table,
            columns: columns,
            joinTable: joinTable,
            joinOn: joinOn,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose));
      } else {
        rows.addAll(await database.select(
            table: table,
            columns: columns,
            offset: offset,
            limit: limit,
            where: where,
            orderBy: orderBy,
            verbose: verbose));
      }
    } catch (e) {
      if (_changefeedIsActive) {
        _rowsController.sink.addError(e);
      } else {
        rethrow;
      }
      return;
    }
    if (_changefeedIsActive) {
      _rowsController.sink.add(rows);
    }
  }
}
