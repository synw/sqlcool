import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sqlcool/sqlcool.dart';

import 'column.dart';
import 'table.dart';

/// A database record
@immutable
class DbRecord<T> {
  /// Default constructor
  DbRecord(this.key, this.value) {
    if (!(value is T)) {
      throw ArgumentError("Provide a value of type $T for record $key");
    }
  }

  /// The record column name
  final String key;

  /// The record value
  final T value;

  /// Get the type
  Type get type => T;

  /// Get a copy of a record with a specific type
  ///
  /// Accepted types: String, int, double, bool
  /// and Uint8List
  DbRecord? copyWithType(Type t) {
    switch (t) {
      case String:
        return DbRecord<String>(key, value.toString());
        break;
      case int:
        try {
          final v = int.parse(value.toString());
          return DbRecord<int>(key, v);
        } catch (e) {
          throw Exception("Can not convert $value to $t "
              "for key $key");
        }
        break;
      case double:
        try {
          final v = double.parse(value.toString());
          return DbRecord<double>(key, v);
        } catch (e) {
          throw Exception("Can not convert $value to $t "
              "for key $key");
        }
        break;
      case bool:
        final dynamic val = value.toString();
        if (val == "true") {
          return DbRecord<bool>(key, true);
        } else if (val == "false") {
          return DbRecord<bool>(key, false);
        } else {
          throw Exception("Can not convert $value to $t "
              "for key $key");
        }
        break;
      case Uint8List:
        try {
          final v = value as Uint8List;
          return DbRecord<Uint8List>(key, v);
        } catch (e) {
          throw Exception("Can not convert $value to $t "
              "for key $key");
        }
        break;
    }
    return null;
  }

  @override
  String toString() {
    return "$key : $value <$type>";
  }
}

/// A database row
@immutable
class DbRow {
  /// Default constructor
  const DbRow(this.records);

  /// Build a row from a single record
  factory DbRow.fromRecord(DbRecord record) => DbRow(<DbRecord>[record]);

  /// Create from a map of strings
  factory DbRow.fromMap(DbTable? table, Map<String, dynamic> row) {
    final recs = <DbRecord>[];
    row.forEach((key, dynamic value) {
      if (key == "id") {
        recs.add(DbRecord<int?>(key, value as int?));
      } else {
        final col = table!.column(key);
        if (col == null) {
          recs.add(DbRecord<dynamic>(key, value));
        } else {
          //print("COL ${col.name} ${col.type}");
          switch (col.type) {
            case DbColumnType.varchar:
              recs.add(DbRecord<String>(key, value.toString()));
              break;
            case DbColumnType.text:
              recs.add(DbRecord<String>(key, value.toString()));
              break;
            case DbColumnType.integer:
              int? v;
              try {
                v = value as int?;
              } catch (e) {
                rethrow;
              }
              recs.add(DbRecord<int?>(key, v));
              break;
            case DbColumnType.real:
              double? v;
              try {
                v = value as double?;
              } catch (e) {
                rethrow;
              }
              recs.add(DbRecord<double?>(key, v));
              break;
            case DbColumnType.boolean:
              bool v;
              if (value == "false") {
                v = false;
              } else if (value == "true") {
                v = true;
              } else {
                throw Exception("Wrong value $value for boolean field $key");
              }
              recs.add(DbRecord<bool>(key, v));
              break;
            case DbColumnType.timestamp:
              int? v;
              try {
                v = value as int?;
              } catch (e) {
                rethrow;
              }
              recs.add(DbRecord<int?>(key, v));
              break;
            case DbColumnType.blob:
              Uint8List? v;
              try {
                v = value as Uint8List?;
              } catch (e) {
                rethrow;
              }
              recs.add(DbRecord<Uint8List?>(key, v));
              break;
          }
        }
      }
    });
    //print("ROW $recs");
    return DbRow(recs);
  }

  /// The row's records
  final List<DbRecord> records;

  /// Get a record value
  T? record<T>(String key) {
    final rec = records.firstWhere((r) => r.key == key);
    T? res;
    if (rec != null) {
      print("REC $rec");
      try {
        if (rec.type != dynamic) {
          final r = rec as DbRecord<T?>;
          res = r.value;
        } else {
          final r = rec.copyWithType(T) as DbRecord<T>;
          res = r.value;
        }
      } catch (e) {
        throw Exception("Type error for record $key : $e");
      }
    }
    return res;
  }

  /// Convert to a map
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    records.forEach((r) => data["${r.key}"] = r.value);
    return data;
  }

  /// Convert to a map of strings
  Map<String, String> toStringsMap() {
    final data = <String, String>{};
    records.forEach((r) => data["${r.key}"] = r.value.toString());
    return data;
  }

  /// Get a string representation
  String line() {
    final l = <String>[];
    records.forEach((rec) {
      l.add("${rec.key} : ${rec.value}");
    });
    return l.join(",");
  }
}
