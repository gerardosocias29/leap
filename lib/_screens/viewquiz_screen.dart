import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ViewQuizScreen extends StatefulWidget {
  final quiz_data;
  const ViewQuizScreen({Key? key, required this.quiz_data}) : super(key: key);

  @override
  State<ViewQuizScreen> createState() => _ViewQuizScreenState();
}

class _ViewQuizScreenState extends State<ViewQuizScreen> {
  final CountDownController _controller = CountDownController();
  final FlutterTts flutterTts = FlutterTts();

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
      body: Container (
        height: double.infinity,
        width: double.infinity,
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
                  duration: widget.quiz_data['timer'] as int,
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
                  widget.quiz_data['quiz_question'],
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),

                if(widget.quiz_data['answer_type'] == 'speak') Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor)
                  ),
                  width: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('${widget.quiz_data['quiz_answer']}', textAlign: TextAlign.center),
                          ),
                          InkWell(
                            child: const Icon(Icons.volume_up),
                            onTap: () async {
                              await flutterTts.speak('${widget.quiz_data['quiz_answer']}');
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

                if(widget.quiz_data['answer_type'] == 'choices') ...(widget.quiz_data['quiz_choices'].split(',') as List).map((answer) {
                  String ans = '$answer';
                  return MaterialButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => {  },
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
                    // if(_speechToText.isNotListening){
                    //   _startListening(),
                    //   setState(() {
                    //     _speakCorrectAnswer = "${questions[_questionIndex]['quiz_answer']}";
                    //   })
                    // } else {
                    //   _stopListening()
                    // }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minWidth: double.infinity,
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: const Text(
                    'Tap the button to start listening...' ,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ]
            )
          )
        )
      )
    );
  }
}
