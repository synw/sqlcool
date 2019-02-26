# Changelog

## 2.1.0

- Add the onReady callback
- Upgrade dependencies

## 2.0.0

**Breaking changes**:

- The default `Db` instance has been removed
- The `database` parameter is now required for `SelectBloc`
- The `changeType` parameter in `changefeed` has been renamed `type` and now uses the `DatabaseChange` data type

New features:

- Add support for the Sqflite debug mode
- Add a query timer
- Add the `query` method

Changes and fixes:

- Add a check to make sure the database is ready before running any query
- Better examples
- Various minor fixes


## 1.2.0

- Downgrade to path_provider 0.4.1
- Add mutexes for write operations
- Add the query to the changefeed info

- Fix return values for update and delete
- Fix bloc select verbose param
- Fix verbosity for update and insert queries
- Improve the example
- Improve the doc and readme

## 1.1.2

Fix: close `_changeFeedController` sink

## 1.1.1

Minor fixes

## 1.1.0

Add changefeed and reactive select bloc

## 1.0.0

Initial release