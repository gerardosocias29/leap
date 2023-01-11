import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class QuizScreen extends StatefulWidget {
  final topic_id;
  const QuizScreen({Key? key, required this.topic_id}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  late var _isloading = false;
  late final List<Map<String, Object>> questions = [];
  final List<Map<String, Object>> _questions = [
    {
      'question': 'Which word is a noun in this sentence? I decided to catch the bus because I was late.',
      'answers': [
        {'text': 'catch', 'score': 0},
        {'text': 'bus', 'score': 1},
        {'text': 'late', 'score': 0},
      ],
    },
    {
      'question': 'Which word is a noun in this sentence? The queue was very long so I didn\'t wait.',
      'answers': [
        {'text': 'queue', 'score': 1},
        {'text': 'long', 'score': 0},
        {'text': 'wait', 'score': 0},
      ],
    },
    {
      'question': 'Which word is a noun in this sentence? There are no interesting programmes on tonight.',
      'answers': [
        {'text': 'interesting', 'score': 0},
        {'text': 'programmes', 'score': 1},
        {'text': 'tonight', 'score': 0},
      ],
    },
    {
      'question': 'Which word is a noun in this sentence? I need to find something that my brother will like.',
      'answers': [
        {'text': 'need', 'score': 0},
        {'text': 'find', 'score': 0},
        {'text': 'brother', 'score': 1},
      ],
    },
    {
      'question': 'Which word is a noun in this sentence? Don\'t be late for the concert.',
      'answers': [
        {'text': 'late', 'score': 0},
        {'text': 'for', 'score': 0},
        {'text': 'concert', 'score': 1},
      ],
    },
  ];
  late var filteredList;
  getQuizList() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/quizzes/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );

    var res = jsonDecode(response.body);
    filteredList = [];
    var topic_id = widget.topic_id;
    var itm;
    for(itm in res){
      print(itm);
      if (itm['topic_id'] != null && itm['topic_id'] == topic_id) {
        var ans = itm['quiz_choices'].split(",");
        var answers = [];
        for(var an in ans){
          var score = 0;
          if(an == itm['quiz_answer']){
            score = 1;
          }
          answers.add({
            "text": an, 'score': score
          });
        }
        questions.add({
          'question': itm['quiz_question'],
          'answers': answers
        });
        print("questions");
        print(questions);
      }
    }

    setState(() {
      print(filteredList);
      _isloading = false;
    });
  }

  void _answerQuestion(int score) {
    _score += score;
    setState(() {
      _questionIndex++;
    });
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getQuizList();
  }

  @override
  Widget build(BuildContext context) {
    if (_questionIndex < questions.length) {
      String quest = '${questions[_questionIndex]['question']}';

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Quiz",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  quest,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                ...(_questions[_questionIndex]['answers'] as List<Map<String, Object>>)
                    .map((answer) {
                  String ans = '${answer['text']}';
                  return ElevatedButton(
                    child: Text(ans),
                    onPressed: () => _answerQuestion(answer["score"] as int),
                  );
                }).toList(),
              ],
            ),
          )
        ),

      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Quiz",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
        ),
        body:SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Text(
                    'You scored $_score out of ${_questions.length}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _resetQuiz,
                    child: const Text('Reset Quiz'),
                  ),
                ],
              ),
            )
          )
        )
      );
    }
  }
}
