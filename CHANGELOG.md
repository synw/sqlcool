# Changelog

# 4.3.0

- Update dependencies
- Fix `boolean` column in schema
- Fix `unique` in schema
- Fix `uniqueTogether` in schema
- Fix edge case in `DbModel.sqlJoin`
- Deprecate `insertIfNotExists`
- Deprecate `DbModels.insertIfNotExists`

# 4.2.0

- Update dependencies
- Add `insertManageConflict` method
- Fix typo in `confligAlgoritm` parameter for `batchInsert`

## 4.1.1

Fix update query constructor bug #16

## 4.1.0

- Use extra_pedantic for stronger analysis_options
- Add more custom exceptions
- Add a `DbModel.sqlInsertIfNotExists` method
- Add a `preserveColumn` parameter to `DbModel.sqlUpsert`

## 4.0.0

- Add informative getters to the schema
- Join on multiple foreign keys
- Database models
- Query support in `SelectBloc`
- Update dependencies
- Use more strict analysis options

## 3.2.1

- Run create queries and schema for asset database
- Use create if not exists in create table query

## 3.2.0

- Update to Dart sdk 2.2.2
- Update dependencies

## 3.1.1

- Use pedantic for static analysis
- Add more tests
- Improve the docs
- Linting

## 3.1.0

- Add a `timestamp` column type to schema
- Add a `data` property to `DatabaseChangeType`
- Fix the `upsert` method to be testable
- Add more tests

## 3.0.0

**Breaking change**: the `SynchronizedMap` feature was removed due to broken dependencies after the Dart Sdk 2.4.0 upgrade

## 2.9.0

- Fix index in `DbTable` in case of same row name for different tables
- Fix the initialization when the `fromAsset` parameter is used
- Fix schema constructor in case of multiple foreign keys
- Add the `timestamp` method to `DbTable`
- Add a `uniqueTogether` method to `DbTable`
- Add a blob method to schema constructor
- Improve the docs for schema definition

## 2.8.2

- Add the columns getter for `DbSchema`
- Fix `defaultValue` for the`real` method of `DbSchema`
- Fix the example

## 2.8.1

- Update dependencies
- Improve schema management
- Minor fix in `SynchronizedMap`
- Add the `hasSchema` getter

## 2.8.0

- Add the `batchInsert` method
- Add the `schema` parameter to `init`
- Improve the `count` method
- Update the changefeed from batchInsert
- Fix nullables in schema constructor
- Improve `foreignKey` in schema constructor

## 2.7.0

- Add the database schema constructor

## 2.6.1

- Add the `columns` parameter to `SychronizedMap`

## 2.6.0

- Add the synchronized map feature

## 2.5.0

- Add the group by sql clause to select and join methods
- Add the upsert method
- Use transactions for all queries
- Remove the default values for offset and limit in join query

## 2.4.0

- Add the ability to use an existing Sqflite database
- Make all the DatabaseChangeEvent parameters final
- Add a table parameter to DatabaseChangeEvent
- Update SelectBloc to use the table parameter of DatabaseChangeEvent
- Use travis-ci builds
- Start adding tests 

## 2.3.0

- Update dependencies
- Add the `update` method to `SelectBloc`

## 2.2.0

- Add the `absolutePath` parameter to the `init` method
- Use more strict linting rules
- Improve docstrings

## 2.1.1

- Fix race condition in SelectBloc
- Fix in the `fromAsset` option of `init`: create the directories path if needed instead of throwing an error

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

