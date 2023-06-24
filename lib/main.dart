import 'package:flutter/material.dart';
import 'package:sevima_quiz_app/quiz_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
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
