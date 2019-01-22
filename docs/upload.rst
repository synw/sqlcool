Upload the database
===================

To upload database to a server:

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   void uploadDb() {
     String url = "http://myserver:8080/upload";
     num statusCode = await db.upload(url);
   }


This will upload the database file to the provided url.

Required parameters:

:serverUrl: *String* the server url

Optional parameter:

:filename: *string* the file name received by the server: default ``db.sqlite``

Returns the http status code sent by the server
