import 'package:flutter/material.dart';

import '../data.dart';
import 'widgets/doughnut_widget.dart';
import 'widgets/operation_line_widget.dart';

class CategoriesPage extends StatefulWidget {
  static const String routeName = '/categories';

  final Map<String, dynamic> args;

  const CategoriesPage({Key? key, required this.args}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  OperationList? list;
  DataProvider? data;
  Category? category;

  @override
  void initState() {
    super.initState();
    int? catId;
    if (widget.args['categoryId'] != null) {
      catId = int.parse(widget.args['categoryId']);
    }
    getOperations(categoryId: catId).then((value) {
      setState(() {
        list = value.debitOperationList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int? operationCount = list?.operations.length;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(operationCount != null ? pageTitle : "Chargement..."),
      ),
      body: Column(
        children: [
          Hero(
            tag: 'donut-cat',
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: DoughnutWidget(
                size: const Size(200, 200),
                data: list != null ? DataProvider(list!.getData()) : null,
                onTapSegment: (segment) {
                  Navigator.of(context).pushNamed(
                    CategoriesPage.routeName,
                    arguments: {"categoryId": "${(segment.ref as Category).id}"},
                  );
                },
              ),
            ),
          ),
          if (list != null) ...buildContent(context, list!),
        ],
      ),
    );
  }

  String get pageTitle {
    return category != null ? category!.name : "Toutes mes opérations";
  }

  List<Widget> buildContent(BuildContext context, OperationList list) {
    return [
      Container(
        height: 20,
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: Text('${list.operations.length} operations'),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: list.operations.length,
          itemBuilder: (context, i) => OperationLineWidget(
            key: Key("ope/$i"),
            operation: list.operations[i],
          ),
        ),
      ),
    ];
  }
}
