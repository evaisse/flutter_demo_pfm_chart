import 'package:flutter/material.dart';

import '../data.dart';
import 'widgets/doughnut_widget.dart';
import 'widgets/operation_line_widget.dart';

class CategoriesPage extends StatefulWidget {
  static const String routeName = '/categories';

  Map<String, dynamic> args;

  CategoriesPage({Key? key, required this.args}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  OperationList? list;
  DataProvider? data;

  @override
  void initState() {
    super.initState();
    getOperations().then((value) {
      setState(() {
        list = value.debitOperationList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    int? operationCount = list?.operations.length;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(operationCount != null ? "$operationCount operations" : "Chargement..."),
      ),
      body: list != null
          ? buildContent(context, list!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget buildContent(BuildContext context, OperationList list) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: DoughnutWidget(
            size: const Size(200, 200),
            data: DataProvider(list.getData()),
          ),
        ),
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
      ],
    );
  }
}
