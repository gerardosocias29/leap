import 'dart:async';
import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_view_screen.dart';

import '../api.dart';
import '../providers/storage.dart';

class QuizScreen extends StatefulWidget {
  final topic_id;
  final topic;
  final user_topic_id;
  const QuizScreen({Key? key, required this.topic_id, required this.topic, required this.user_topic_id}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CountDownController _controller = CountDownController();
  int _questionIndex = 0;
  int _score = 0;
  late var _isloading = false;
  late final List<Map<String, Object>> questions = [];

  late var filteredList;
  late int timer_start = 0;
  late final userDetails;
  late final utqId;
  final userStorage = StorageProvider().userStorage();
  late var quiz_type = "";

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

  setQuizList(data) async {
    filteredList = [];
    for(var itm in data){
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
    // _controller.start();
  }

  void _answerQuestion(int score) {
    _score += score;
    setState(() {
      _questionIndex++;
    });
  }

  void _submitScore() {
    print('utqId:: $utqId');
    if( utqId != 0 && utqId != null ){
      makePostRequest({
        'user_id': userDetails['id'],
        'user_topic_id': widget.user_topic_id,
        'quiz_id': questions.length,
        'score': _score,
        'status': 'taken',
        'quiz_type': quiz_type,
      }, 'user_topic_quiz/update/$utqId');
    } else {
      makePostRequest({
        'user_id': userDetails['id'],
        'user_topic_id': widget.user_topic_id,
        'quiz_id': questions.length,
        'score': _score,
        'status': 'taken',
        'quiz_type': quiz_type,
      }, 'user_topic_quiz/create');
    }
    Navigator.of(context).pop(true);
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TopicViewScreen(topic: widget.topic)) );
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

  getData(quiz_type) async {
    var urls = [
      'user_topics_quiz/${userDetails['id']}/${widget.user_topic_id}/$quiz_type', // 0
      'topic_quiz_list/${widget.topic_id}/$quiz_type', // 1
    ];
    var datas = await Api().multipleGetRequest(urls);

    setState(() {
      print('datas[0][status]:: ${datas[0]['status']}');
      if(datas[0]['status'] == false){
        utqId = 0;
      } else {
        utqId = datas[0]['id'];
      }

      setQuizList(datas[1]);
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
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
        )
      ),
      body: (quiz_type == '') ?
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                color: Theme.of(context).primaryColor,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: const Text(
                  'Easy',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => {
                  setState(() {
                    quiz_type = 'easy';
                    getData(quiz_type);
                  })
                },
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                color: Theme.of(context).primaryColor,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: const Text(
                  'Medium',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => {
                  setState(() {
                    quiz_type = 'medium';
                    getData(quiz_type);
                  })
                },
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                color: Theme.of(context).primaryColor,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: const Text(
                  'Hard',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => {
                  setState(() {
                    quiz_type = 'hard';
                    getData(quiz_type);
                  })
                },
              ),
            ],
          ),
        )
      : (_isloading ?
        const Center(
          child: CircularProgressIndicator(),
        )
      : ((_questionIndex < questions.length) ? SingleChildScrollView(
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
                '${_questionIndex + 1}. ${questions[_questionIndex]['question']}',
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
      ) : SingleChildScrollView(
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
      ) )) ,
    );
  }
}
