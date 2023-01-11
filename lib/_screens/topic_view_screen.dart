import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:leap/_screens/quiz_screen.dart';

import '../navbar.dart';
import '../providers/storage.dart';

class TopicViewScreen extends StatefulWidget {
  final topic;
  const TopicViewScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<TopicViewScreen> createState() => _TopicViewScreenState();
}

class _TopicViewScreenState extends State<TopicViewScreen> {
  late FlutterTts flutterTts;
  bool isPlaying = false;

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
      });
    });
  }

  Future _readText() async {
    await flutterTts.setVolume(2);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(0);

    var result = await flutterTts.speak(text);
    if (result == 1) {
      setState(() {
        isPlaying = true;
      });
    }
  }

  _stopRead () {
    flutterTts.stop();
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
      drawer: _isloading ? null : NavBar(userDetails: userDetails),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              InkWell(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: isPlaying ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                      onPressed: () => {}
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      child: Text(isPlaying ? 'Stop' : 'Play',
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
              const SizedBox(
                height: 10,
              ),
              Text(
                '''${widget.topic['topic_details']}''',
                style: const TextStyle(fontSize: 18.0, ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              //...
            },
            heroTag: null,
            label: const Text('Add Quiz'),
            icon: const Icon(
                Icons.add
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              //...
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => QuizScreen(topic_id: widget.topic['id'])), (route) => true );
            },
            heroTag: null,
            label: const Text('Take Quiz'),
            icon: const Icon(
                Icons.assignment
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ]
      )
    );
  }
}