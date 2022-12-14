import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_pfmbudget/src/widgets/doughnut_widget.dart';

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
  List<Category>? children;

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

  /// build parent categories
  for (var element in catJson) {
    var c = element as Map<String, dynamic>;
    var cat = _categories.firstWhere((element) => element.id == c['id']);
    if (c['parentId'] != null) {
      var id = int.parse(c['parentId']);
      cat.parent = _categories.firstWhere((element) => element.id == id);
    }
  }

  /// build categories children
  for (var parent in _categories.where((c) => c.parent == null)) {
    parent.children = _categories.where((element) => element.parent == parent).toSet().toList();
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

Future<OperationList> getOperations({int? categoryId}) async {
  await _load();
  if (categoryId != null && _categories.where((element) => element.id == categoryId).isNotEmpty) {
    return OperationList(_operations.where((element) => element.category.id == categoryId).toList());
  }
  return OperationList(_operations);
}

class OperationList {
  final List<Operation> operations;

  OperationList(this.operations);

  OperationList get debitOperationList => OperationList(operations.where((e) => e.amount < 0).toList());
  OperationList get creditOperationList => OperationList(operations.where((e) => e.amount >= 0).toList());

  List<Category> get categories => operations.map((e) => e.category).toSet().toList();
  List<Category> get parentCategories => categories.where((element) => element.parent == null).toSet().toList();

  double get amount => (operations.map((e) => e.amount).toList().reduce((a, b) => a + b));

  List<SegmentData> getData() {
    return parentCategories.map((cat) {
      var amount = operations
          .where((element) {
            /// fetch all operations that match parent of child of parent;
            return element.category == cat || element.category.parent == cat;
          })
          .map((e) => e.amount)
          .reduce((a, b) => a + b);
      return SegmentData(label: cat.name, value: amount, color: cat.color, ref: cat);
    }).toList();
  }
}
