import 'dart:async';
import 'package:example/pages/dbmodels/model.dart';
import 'package:sqlcool/sqlcool.dart';
import '../../conf.dart';

DbModelTable dataModelTable;

final _readyCompleter = Completer<Null>();

Future get onDbModelConfReady => _readyCompleter.future;

Future<void> initDbModelConf() async {
  // if this conf function is called several times
  if (_readyCompleter.isCompleted) {
    return;
  }
  // set the model table schema. We use the main db
  dataModelTable = DataModel.tableSchema(db: db);
  // do not forget to initialize the schema
  // this will add the table to the db if it does not exist
  await dataModelTable.init(verbose: true);
  _readyCompleter.complete();
}
