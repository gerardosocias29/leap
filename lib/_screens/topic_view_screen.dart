import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/quiz_screen.dart';
import 'package:leap/_screens/quizlist_screen.dart';
import 'package:workmanager/workmanager.dart';

import '../api.dart';
import '../main.dart';
import '../navbar.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class TopicViewScreen extends StatefulWidget {
  final topic;
  final chapter_name;
  const TopicViewScreen({Key? key, required this.topic, required this.chapter_name}) : super(key: key);

  @override
  State<TopicViewScreen> createState() => _TopicViewScreenState();
}

class _TopicViewScreenState extends State<TopicViewScreen> {
  late FlutterTts flutterTts;
  bool isPlaying = false;
  bool showBtn = false;
  late final userDetails;
  late var _isloading = false;
  final userStorage = StorageProvider().userStorage();
  String text = "Hello World!";
  Future _initRetrieval() async {
    flutterTts = FlutterTts();

    setState(() {
      _isloading = true;
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
      text = "${widget.topic['topic_details']}";
    });

    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        showBtn = true;
      });
      if(!isTopicDone){
        makePostRequest({
          'user_id' : userDetails['id'],
          'topic_id' : widget.topic['id'],
          'status' : 'done'
        }, 'user_topic/create');
      }
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    getUserTopics();

    /*var uniqueId = DateTime.now().second.toString();
    await Workmanager().registerOneOffTask(
        uniqueId,
        'notif',
        inputData: {
          'test': 'test'
        },
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(networkType: NetworkType.connected)
    );*/
  }

  bool isTopicDone = false;
  late var userTopicId = 0;
  getUserTopics() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/user_topic/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );
    var res = jsonDecode(response.body);
    for(var itm in res){
      if (itm['user_id'] == userDetails['id'] && itm['topic_id'] == widget.topic['id']) {
        setState(() {
          isTopicDone = true;
          userTopicId = itm['id'];
        });
      }
    }
    setState(() {
      print("isTopicDone::: $isTopicDone $userTopicId");
      _isloading = false;
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

    getUserTopics();
    setState(() {
      Api().getAchievements(userDetails['id'], 'finished_lessons');
    });

  }

  Future _readText() async {
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);

    var count = text.length;
    var max = 4000;
    var loopCount = count ~/max;
    var result;
    for( var i = 0 ; i <= loopCount; i++ ) {
      if (i != loopCount) {
        result = await flutterTts.speak(text.substring(i*max, (i+1)*max));
      } else {
        var end = (count - ((i*max))+(i*max));
        result = await flutterTts.speak(text.substring(i*max, end));
      }
    }
    // var result = await flutterTts.speak(text);
    if (result == 1) {
      setState(() {
        isPlaying = true;
      });
    }
  }

  _stopRead () {
    flutterTts.pause();
    setState(() { isPlaying = false; });
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${widget.topic['topic_title']}",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: Container(
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
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Material(
                  child: InkWell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: isPlaying ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
                          onPressed: () => {}
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          child: Text(isPlaying ? 'Pause' : 'Play',
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                            )
                          )
                        )
                      ]
                    ),
                    onTap: () => isPlaying ? _stopRead() : _readText(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '''${widget.topic['topic_details']}''',
                  style: const TextStyle(fontSize: 18.0, ),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(
                  height: 30,
                ),

                if(isTopicDone) const Text("Completed!"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (userDetails['role_id'] == 0) FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => QuizListScreen(topic_id: widget.topic['id'] )), (route) => true );
            },
            heroTag: null,
            label: const Text('Quiz List'),
            icon: const Icon(
                Icons.list_alt_outlined
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (showBtn || userDetails['role_id'] == 0 || isTopicDone) FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => QuizScreen(topic_id: widget.topic['id'], topic: widget.topic, user_topic_id: userTopicId, chapter_name: widget.chapter_name)), (route) => true );
            },
            heroTag: null,
            label: const Text('Take Quiz'),
            icon: const Icon(
                Icons.assignment
            ),
          )
        ]
      )
    );
  }
}