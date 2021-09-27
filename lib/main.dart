import 'package:flutter/material.dart';
import 'package:todo_list/pages/home.dart';
import 'package:todo_list/pages/tour.dart';
import 'package:todo_list/storage.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.grey[900],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(storage: ItemsStorage()),
        '/tour': (context) => TourPage(),
      },
    ),
  );
}
