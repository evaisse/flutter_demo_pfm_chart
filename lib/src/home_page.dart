import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';

  Map<String, dynamic> args;

  HomePage({Key? key, required this.args}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(runtimeType.toString()),
      ),
      body: Container(
        child: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/categories'),
            child: Text('Go !'),
          ),
        ),
      ),
    );
  }
}
