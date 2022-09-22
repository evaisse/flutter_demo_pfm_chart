import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';

extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class Category {
  int id;
  String name;
  Color color;
  Category? parent;

  Category({required this.id, required this.name, required this.color, required this.parent});
}

class Operation {
  int id;
  Category category;
  double amount;
  DateTime date;
  String label;

  Operation({required this.id, required this.category, required this.amount, required this.date, required this.label});
}

final List<Category> _categories = [];
final List<Operation> _operations = [];

Future<void> _load() async {
  if (_categories.isNotEmpty) return;

  var catJson = jsonDecode(await rootBundle.loadString('assets/json/cats.json')) as List;
  for (var element in catJson) {
    var c = element as Map<String, dynamic>;
    _categories.add(Category(id: c['id'], name: c['label'], color: (c['color'] as String).toColor(), parent: null));
  }

  var opId = 1;
  var opeJson = jsonDecode(await rootBundle.loadString('assets/json/ops.json')) as List;
  for (var element in opeJson) {
    var c = element as Map<String, dynamic>;
    var amount = 0.0;
    try {
      amount = c['amount'] as double;
    } catch (e) {
      amount = (c['amount'] as int).toDouble();
    }
    try {
      _operations.add(Operation(
        id: opId++,
        label: c['label'],
        amount: amount,
        date: DateTime.parse(c['date']),
        category: _categories.firstWhere((cat) => cat.id == (c['category'] as int)),
      ));
    } catch (e) {
      continue;
    }
  }
  return Future.delayed(Duration(milliseconds: Random().nextInt(700)));
}

Future<List<Category>> getCategories() async {
  await _load();
  return _categories;
}

Future<OperationList> getOperations({Category? category}) async {
  await _load();
  if (category != null) {
    return OperationList(_operations.where((element) => element.category == category).toList());
  }
  return OperationList(_operations);
}

class OperationList {
  final List<Operation> operations;

  OperationList(this.operations);

  List<Category> get categories => operations.map((e) => e.category).toSet().toList();

  double get amount => (operations.map((e) => e.amount).toList().reduce((a, b) => a + b));
}
