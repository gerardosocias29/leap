import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;

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
  Widget build(BuildContext context) {
    if (_questionIndex < _questions.length) {
      String quest = '${_questions[_questionIndex]['question']}';

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
                  style: TextStyle(fontSize: 18),
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
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text('Reset Quiz'),
                    onPressed: _resetQuiz,
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
