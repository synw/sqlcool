# Changelog

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

