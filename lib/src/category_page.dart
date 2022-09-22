import 'package:flutter/material.dart';

///
/// @see fake services : https://github.com/bizz84/slivers_demo_flutter/blob/master/lib/pages/networking/networking_page_content.dart
///
class CategoryPage extends StatefulWidget {
  static const String routeName = '/category';

  Map<String, dynamic> args;

  CategoryPage({Key? key, required this.args}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.runtimeType.toString()),
      ),
      body: Container(),
    );
  }
}
