import 'package:flutter/material.dart';

import '../../data.dart';

class OperationLineWidget extends StatelessWidget {
  final Operation operation;

  const OperationLineWidget({Key? key, required this.operation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              color: operation.category.color,
              child: Text(operation.label),
            )
          ],
        ),
        Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.all(8.0),
              child: Text("${operation.amount} EUR"),
            )
          ],
        ),
      ],
    );
  }
}
