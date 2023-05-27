import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/quiz_screen.dart';
import 'package:leap/_screens/quizlist_screen.dart';
import 'package:leap/app_theme.dart';
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

class _TopicViewScreenState extends State<TopicViewScreen> with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;

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

    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
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

    setState(() {
      Api().getAchievements(userDetails['id'], 'finished_lessons', context);
      getUserTopics();
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
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    _initRetrieval();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.5) +
        24.0;
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.5,
                  child: (widget.chapter_name.toString().toLowerCase() == "grammar") ? Image.asset('assets/grammar.png') : Image.asset('assets/pronunciation.jpg'),
                ),
              ],
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.5) - 24.0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.nearlyWhite,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: AppTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                          minHeight: infoHeight,
                          maxHeight: tempHeight > infoHeight
                              ? tempHeight
                              : infoHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 32.0, left: 18, right: 16),
                            child: Text(
                              '${widget.topic['topic_title']}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                letterSpacing: 0.27,
                                color: AppTheme.darkerText,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 8, top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (isTopicDone) const Text(
                                  'Completed',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 16,
                                    letterSpacing: 0.27,
                                    color: AppTheme.nearlyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 8),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Text(
                                    '''${widget.topic['topic_details']}''',
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 0.27,
                                      color: AppTheme.teal,
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: opacity3,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, bottom: 0, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  if (userDetails['role_id'] == 0) InkWell(
                                    onTap: () { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => QuizListScreen(topic_id: widget.topic['id'] )), (route) => true ); },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.nearlyWhite,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(16.0),
                                          ),
                                          border: Border.all(
                                              color: AppTheme.grey
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Quiz List',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              color: AppTheme
                                                  .nearlyWhite,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (userDetails['role_id'] == 0) ? 0 : 8,
                                  ),
                                  if (showBtn || userDetails['role_id'] == 0 || isTopicDone) Expanded(
                                    child: Center(
                                      child: InkWell(
                                        onTap: () { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => QuizScreen(topic_id: widget.topic['id'], topic: widget.topic, user_topic_id: userTopicId, chapter_name: widget.chapter_name)), (route) => true ); },
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppTheme.nearlyBlue,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(16.0),
                                            ),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: AppTheme
                                                      .nearlyBlue
                                                      .withOpacity(0.5),
                                                  offset: const Offset(1.1, 1.1),
                                                  blurRadius: 10.0),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Take Quiz',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                letterSpacing: 0.0,
                                                color: AppTheme
                                                    .nearlyWhite,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0 - 35,
              right: 35,
              child: ScaleTransition(
                alignment: Alignment.center,
                scale: CurvedAnimation(
                    parent: animationController!, curve: Curves.fastOutSlowIn),
                child: InkWell(
                  onTap: () => isPlaying ? _stopRead() : _readText(),
                  child: Card(
                    color: AppTheme.nearlyBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    elevation: 10.0,
                    child: Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.nearlyWhite,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: SizedBox(
                width: AppBar().preferredSize.height,
                height: AppBar().preferredSize.height,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(AppBar().preferredSize.height),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppTheme.nearlyBlack,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );

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

Widget getTimeBoxUI(String text1, String txt2) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.nearlyWhite,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.grey.withOpacity(0.2),
              offset: const Offset(1.1, 1.1),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              text1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.27,
                color: AppTheme.nearlyBlue,
              ),
            ),
            Text(
              txt2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 14,
                letterSpacing: 0.27,
                color: AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}