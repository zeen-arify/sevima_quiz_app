import 'package:flutter/material.dart';
import 'package:sevima_quiz_app/quiz_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sevima Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: QuizPage(),
    );
  }
}
