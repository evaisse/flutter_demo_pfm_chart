import 'package:flutter/material.dart';
import 'package:flutter_pfmbudget/src/operation_line_widget.dart';

import '../data.dart';
import 'doughnut_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OperationList? list;

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

  List<SegmentData> buildSegments(OperationList list) {
    return list.parentCategories.map((cat) {
      var amount = list.operations
          .where((element) {
            /// fetch all operations that match parent of child of parent;
            return element.category == cat || element.category.parent == cat;
          })
          .map((e) => e.amount)
          .reduce((a, b) => a + b);
      return SegmentData(
        label: cat.name,
        value: amount,
        color: cat.color,
      );
    }).toList();
  }

  Widget buildContent(BuildContext context, OperationList list) {
    var segments = buildSegments(list);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: DoughnutWidget(
            size: const Size(200, 200),
            data: DataProvider(segments),
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
