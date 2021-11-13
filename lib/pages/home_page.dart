import 'package:flutter/material.dart';
import 'package:happyscan/styles/colors.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fabBtn(),
    );
  }

  Widget fabBtn() {
    return const FloatingActionButton(
      onPressed: null,
      backgroundColor: accentColor,
      child: Icon(Icons.camera),
    );
  }
}
