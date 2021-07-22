import 'package:flutter/foundation.dart';
import 'package:sqlcool/src/schema/models/table.dart';

///The upgrade class
class Upgrade {

  ///Upgrade version
  final int version;

  ///Upgrade queries
  final List<String> queries;

  ///Upgrade new schema
  final List<DbTable> schema;

  ///Upgrade model representation
  Upgrade({@required this.version, this.queries = const <String>[], this.schema = const <DbTable>[]});
}
