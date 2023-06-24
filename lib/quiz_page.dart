import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

const apiKey = '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';
const apiEndpoint = 'https://api.openai.com/v1/chat/completions';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String selectedSubject = '';
  String selectedDifficulty = '';
  String question = '';
  String answer = '';
  String correction = '';

  List<String> subjects = ['Biologi', 'Informatika', 'Sejarah'];
  List<String> difficulties = ['Mudah', 'Sedang', 'Sulit'];

  void generateQuestion() async {
    final requestBody = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {
          "role": "user",
          "content":
              "Buatkan satu pertanyaan tentang $selectedSubject dengan tingkat kesulitan yang $selectedDifficulty."
        }
      ]
    });

    final response = await http.post(
      Uri.parse(apiEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        question = data['choices'][0]['message']['content'].toString();
      });
    } else {
      setState(() {
        question = 'Gagal membuat pertanyaan, silakan coba lagi!';
      });
    }
  }

  void submitAnswer() async {
    final requestBody = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Q: $question"},
        {"role": "user", "content": "A: $answer"}
      ]
    });

    final response = await http.post(
      Uri.parse(apiEndpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        correction = data['choices'][0]['message']['content'].toString();
      });
    } else {
      setState(() {
        correction = 'Gagal mengirim jawaban, silakan coba lagi!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sevima Quiz App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Materi:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: subjects.map((subject) {
                return ChoiceChip(
                  label: Text(subject),
                  selected: selectedSubject == subject,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedSubject = isSelected ? subject : '';
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Pilih Kategori Pertanyaan:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: difficulties.map((difficulty) {
                return ChoiceChip(
                  label: Text(difficulty),
                  selected: selectedDifficulty == difficulty,
                  onSelected: (isSelected) {
                    setState(() {
                      selectedDifficulty = isSelected ? difficulty : '';
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              onPressed:
                  (selectedSubject.isNotEmpty && selectedDifficulty.isNotEmpty)
                      ? generateQuestion
                      : null,
              child: Text('Buat Pertanyaan'),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Jawablah Pertanyaan Berikut:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(question),
            SizedBox(
              height: 16.0,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  answer = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Jawaban',
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              onPressed: (answer.isNotEmpty) ? submitAnswer : null,
              child: Text('Kirim Jawaban'),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Hasil Koreksi Jawaban:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(correction),
          ],
        ),
      ),
    );
  }
}
