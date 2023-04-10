import 'dart:async';
import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart';
import 'package:leap/reusable_widgets/reusable_widget.dart';

import '../api.dart';
import '../providers/storage.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class QuizScreen extends StatefulWidget {
  final topic_id;
  final topic;
  final user_topic_id;
  final chapter_name;
  const QuizScreen({Key? key, required this.topic_id, required this.topic, required this.user_topic_id, required this.chapter_name}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _speakCorrectAnswer = '';
  bool _isListening = false;

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
  late var answer_checker = "";
  late var count_wrong_pronounce = 0;
  late var correct_word = 0;

  Future _initRetrieval() async {
    userDetails = jsonDecode(await StorageProvider().storageGetItem(userStorage, 'user_details'));
    setState(() {
      _isloading = true;
    });
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenMode: ListenMode.confirmation,
      partialResults: true,
      listenFor: const Duration(seconds: 3),
      pauseFor: const Duration(seconds: 3),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    _lastWords = result.recognizedWords;
    if(_speechToText.isNotListening){
      print("_lastWords:: $_lastWords :: $_speakCorrectAnswer");
      if(_speakCorrectAnswer.toLowerCase() == _lastWords){
        _answerQuestion(1);
      } else {
        count_wrong_pronounce++;
        setState(() {
          answer_checker = "Mispronounced Word";
        });
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          answer_checker = "";
        });
      }
    }
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
        'answers': answers,
        'answer_type': itm['answer_type'],
        'quiz_answer' : itm['quiz_answer']
      });
    }
    // _controller.start();
  }

  Future _answerQuestion(int score) async {
    _score += score;
    setState(() {
      answer_checker = (score == 1) ? "Correct" : "Wrong";
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      answer_checker = "";
      count_wrong_pronounce = 0;
      _questionIndex++;
    });
  }

  Future<void> _submitScore() async {
    print('utqId:: $utqId');
    if( utqId != 0 && utqId != null ){
      var response = await Api().putRequest({
        'user_id': userDetails['id'],
        'user_topic_id': widget.user_topic_id,
        'quiz_id': questions.length,
        'score': _score,
        'status': 'taken',
        'quiz_type': quiz_type,
      }, 'user_topic_quiz/update/$utqId');
      print(response);
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
    setState(() {
      Api().getAchievements(userDetails['id'], 'all_quizzes');
    });
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
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  @override
  void dispose(){
    _speechToText.stop();
    super.dispose();
  }

  int times = 0;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero,() {
      var grammar = '(The grammar quiz is about multiple choices to answer. Follow the following steps for you to be able to answer the given word in each item.)\n1. Select the Quiz Type to take.\n2. Select the answer from the given total time of all items.\n3. If time goes to zero, you will not be allowed to proceed to the next item and it will cut off all the items left.\n4. Choose the desired answer from the given question and choices.\n5. Select the answer to proceed to the next question.\n6.  After taking the quiz, please click the "submit" button to record the score.';
      var speech = '(The pronunciation quiz is about to speak the given word. Follow the following steps for you to be able to answer the given word in each item.)\n1. Select the Quiz Type to take.\n2. Pronounce the word from the given total time of all items.\n3. If time goes to zero, you will not be allowed to proceed to the next item and will cut off all the items left.\n4. Click the "speaker icon" to know and listen to how to pronounce the given word.\n5. Tap the "Listening button to start pronouncing the word".\n6. If you are not able to pronounce the word, input the word given in the box to proceed to the next word to pronounce.\n7. After taking the quiz, please click the "submit" button to record the score.';
      if(times == 0){
        if(widget.chapter_name.toString().toLowerCase() == "grammar"){
          showNotificationDialog(context, grammar);
        } else {
          showNotificationDialog(context, speech);
        }
      }
      times++;
    });
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
        Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 0.5, 0.7, 1],
              colors: [
                Color(0xffffffff),
                Color(0xfffafdff),
                Color(0xffE7FFFF),
                Color(0xffE7FFFF),
              ],
            ),
          ),
          child: Padding(
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
          ),
        )
      : (_isloading ?
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 0.5, 0.7, 1],
              colors: [
                Color(0xffffffff),
                Color(0xfffafdff),
                Color(0xffE7FFFF),
                Color(0xffE7FFFF),
              ],
            ),
          ),
          child:
          const Center(
            child: CircularProgressIndicator(),
          )
        )
      : ((_questionIndex < questions.length) ? Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
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
                if(questions[_questionIndex]['answer_type'] == 'speak') Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor)
                  ),
                  width: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('${questions[_questionIndex]['quiz_answer']}', textAlign: TextAlign.center,),
                          ),
                          InkWell(
                            child: Icon(Icons.volume_up),
                            onTap: () async {
                              // this will prevent in cheating.. if not added, can bypass the word by clicking Button to start listening then clicking the Volume Speaker icon will pronounce the word correctly
                              if(_speechToText.isListening){
                                _stopListening();
                                await flutterTts.speak('${questions[_questionIndex]['quiz_answer']}');
                              }

                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if(questions[_questionIndex]['answer_type'] == 'choices') ...(questions[_questionIndex]['answers'] as List)
                    .map((answer) {
                  String ans = '${answer['text']}';
                  return MaterialButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => (answer_checker != "") ? null : _answerQuestion(answer["score"] as int),
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
                }).toList()
                else MaterialButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () => {
                    if(_speechToText.isNotListening){
                      _startListening(),
                      setState(() {
                        _speakCorrectAnswer = "${questions[_questionIndex]['quiz_answer']}";
                      })
                    } else {
                      _stopListening()
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minWidth: double.infinity,
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    _speechToText.isNotListening ? 'Tap the button to start listening...' : 'Listening...' ,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if(count_wrong_pronounce > 2) TextFormField(
                  // controller: choicesController,
                  decoration: reusableInputDecoration(context, 'Please type the word to proceed', 'Type the word to proceed'),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  onFieldSubmitted: (String value) => {
                    if(value.toLowerCase() == "${questions[_questionIndex]['quiz_answer']}".toLowerCase()){
                      _answerQuestion(1)
                    } else {
                      // _answerQuestion(0)
                      setState(() {
                        answer_checker = "";
                        count_wrong_pronounce = 0;
                        _questionIndex++;
                      })
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                if(answer_checker != "") Text(
                  answer_checker,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: answer_checker.toLowerCase() == 'correct' ? Colors.green : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ),
      ) : Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
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
        ),
      ) )) ,
    );
  }
}
