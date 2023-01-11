import 'dart:async';
import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_view_screen.dart';

import '../providers/storage.dart';

class QuizScreen extends StatefulWidget {
  final topic_id;
  final topic;
  const QuizScreen({Key? key, required this.topic_id, required this.topic}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CountDownController _controller = CountDownController();
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
  late int timer_start = 0;
  late final userDetails;
  late final utqId;
  final userStorage = StorageProvider().userStorage();
  Future _initRetrieval() async {
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

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
    for(var itm in res){
      if (itm['topic_id'] != null && itm['topic_id'] == topic_id) {
        var time = itm['timer'];
        timer_start = timer_start + time as int;
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
      }
    }

    setState(() {
      print("timer:: $timer_start");
      _isloading = false;
    });
    _controller.start();
  }

  void _answerQuestion(int score) {
    _score += score;
    setState(() {
      _questionIndex++;
    });
  }

  void _submitScore() {
    if(utqId != null){
      setState(() {
        makePostRequest({
          'user_id': userDetails['id'],
          'user_topic_id': widget.topic_id,
          'quiz_id': questions.length,
          'score': _score,
          'status': 'taken',
        }, 'user_topic_quiz/update/$utqId');
      });
    } else {
      setState(() {
        makePostRequest({
          'user_id': userDetails['id'],
          'user_topic_id': widget.topic_id,
          'quiz_id': questions.length,
          'score': _score,
          'status': 'taken',
        }, 'user_topic_quiz/create');
      });
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TopicViewScreen(topic: widget.topic)) );
  }

  getUserTopicsQuiz() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/user_topic_quiz/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );
    var res = jsonDecode(response.body);
    var utq;
    for(var itm in res){
      if (itm['user_id'] == userDetails['id'] && itm['user_topic_id'] == widget.topic_id) {
        utq = itm['id'];
      }
    }
    setState(() {
      utqId = utq;
      print('utqId:: $utqId');
    });
  }

  makePostRequest(requestBody, url) async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    print("backendUrl::$backendUrl/api/$url");
    final uri = Uri.parse("$backendUrl/api/$url");
    final headers = {'content-type': 'application/json'};
    Map<String, dynamic> body = requestBody;
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    print("statusCode::$statusCode");
    print(requestBody);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isloading = true;
    });
    getUserTopicsQuiz();
    _initRetrieval();
    getQuizList();
  }

  @override
  Widget build(BuildContext context) {
    if (_questionIndex < questions.length) {
      String quest = '${questions[_questionIndex]['question']}';

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
          actions: <Widget>[
            Text('$timer_start'),
          ]
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularCountDownTimer(
                  duration: timer_start,
                  initialDuration: 0,
                  controller: _controller,
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 4,
                  ringColor: Colors.grey[300]!,
                  ringGradient: null,
                  fillColor: Colors.purpleAccent[100]!,
                  fillGradient: null,
                  backgroundColor: Colors.purple[500],
                  backgroundGradient: null,
                  strokeWidth: 10.0,
                  strokeCap: StrokeCap.round,
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  isReverse: true,
                  isReverseAnimation: true,
                  isTimerTextShown: true,
                  autoStart: true,
                  onStart: () {
                    debugPrint('Countdown Started');
                  },
                  onComplete: () {
                    debugPrint('Countdown Ended');
                    setState(() {
                      _questionIndex = questions.length;
                    });
                  },
                  onChange: (String timeStamp) {
                    debugPrint('Countdown Changed $timeStamp');
                  },
                  timeFormatterFunction: (defaultFormatterFunction, duration) {
                    if (duration.inSeconds == 0) {
                      // only format for '0'
                      return "0";
                    } else {
                      // other durations by it's default format
                      return Function.apply(defaultFormatterFunction, [duration]);
                    }
                  },
                ),
                Text(
                  '${_questionIndex + 1}. $quest',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ...(questions[_questionIndex]['answers'] as List)
                    .map((answer) {
                  String ans = '${answer['text']}';
                  return MaterialButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _answerQuestion(answer["score"] as int),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minWidth: double.infinity,
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      ans,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
          automaticallyImplyLeading: false,
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
                    'You scored $_score out of ${questions.length}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _submitScore,
                    child: const Text('Submit Score'),
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
