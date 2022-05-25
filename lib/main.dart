import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todolist/pages/todolist_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodolistPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}