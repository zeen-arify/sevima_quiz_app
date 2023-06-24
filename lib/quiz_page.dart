import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';
String apiEndpoint = dotenv.env['API_ENDPOINT'] ?? '';

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
  bool isQuestionGenerated = false;

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
        isQuestionGenerated = true;
        answer = '';
        correction = '';
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
        {"role": "user", "content": "Apakah jawaban A: $answer"},
        {"role": "user", "content": "bisa menjawab pertanyaan Q: $question"},
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

  void resetQuestion() {
    setState(() {
      question = '';
      answer = '';
      correction = '';
      isQuestionGenerated = false;
      selectedSubject = '';
      selectedDifficulty = '';
    });
  }

  void generateNewQuestion() {
    setState(() {
      question = '';
      answer = '';
      correction = '';
      isQuestionGenerated = false;
    });
    generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sevima Quiz App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              if (!isQuestionGenerated)
                ElevatedButton(
                  onPressed: (selectedSubject.isNotEmpty &&
                          selectedDifficulty.isNotEmpty)
                      ? generateQuestion
                      : null,
                  child: Text('Buat Pertanyaan'),
                ),
              if (question.isNotEmpty) ...[
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
                  child: Text('Cek Jawaban'),
                ),
              ],
              if (correction.isNotEmpty) ...[
                Text(
                  'Hasil Koreksi Jawaban:',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(correction),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: resetQuestion,
                      child: Text('Ganti Materi'),
                    ),
                    ElevatedButton(
                      onPressed: generateNewQuestion,
                      child: Text('Pertanyaan Lain'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
