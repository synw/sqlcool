Using the bloc pattern for select
=================================

A stream controller is available for select blocs

Select bloc
-----------

.. highlight:: dart

::

   import 'package:sqlcool/sqlcool.dart';

   class _CategoriesPageState extends State<CategoriesPage> {
      SelectBloc bloc;

      _CategoriesPageState();

      @override
      void initState() {
         super.initState();
         // select the data
         this.bloc = SelectBloc("category", offset: 10, limit: 20);
      }

      @override
      void dispose() {
         this.bloc.dispose();
         super.dispose();
      }

      @override
      Widget build(BuildContext context) {
         return Scaffold(
            body: StreamBuilder<List<Map<String, dynamic>>>(
               stream: this.bloc.items,
               builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                     if (snapshot.hasData) {
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> item = snapshot.data[index];
                            // ....
                            // ....
                        }
                     }
                  }
               )));
        }
   }

``SelectBloc`` class:

Required positional parameter:

:table: *String* name of the table, required

Optional named parameters:

:select: *String* the select sql clause
:where: *String* the where sql clause
:joinTable: *String* join table name
:joinOn: *String* join on sql clause
:orderBy: *String* the sql order_by clause
:limit: *int* the sql limit clause
:offset: *int* the sql offset clause
:verbose: *bool* ``true`` or ``false``

Join queries
------------

::

   @override
   void initState() {
      super.initState();
      this.bloc = SelectBloc("product", offset: 10, limit: 20,
                             select: "id, name, price, category.name as category_name",
                             joinTable: "category",
                             joinOn: "product.category=category.id");
   }
