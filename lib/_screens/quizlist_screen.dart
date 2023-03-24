import 'package:flutter/material.dart';

import '../api.dart';
import '../reusable_widgets/reusable_widget.dart';

class QuizListScreen extends StatefulWidget {
  final topic_id;
  const QuizListScreen({Key? key, required this.topic_id}) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late bool _isloading = false;
  late var quizlists;
  
  Future _initRetrieval() async {
    var urls = [
      'topic_quiz_list/${widget.topic_id}/all', // 0
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      quizlists = datas[0];
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isloading = true;
    });
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Quiz Lists',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: _isloading ?
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
        : Container(
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
        child: RefreshIndicator(
          onRefresh: () async { _initRetrieval(); },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: quizlists.length,
            itemBuilder: (context, index) {
              final item = quizlists[index];
              return Card(
                child: ListTile(
                    title: Text("${item['quiz_question']}"),
                    subtitle: Text(item['quiz_type'].toString().toUpperCase()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20.0,
                            // color: Colors.black,
                          ),
                          onPressed: () {
                            //   _onDeleteItemPressed(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outlined,
                            size: 20.0,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            //   _onDeleteItemPressed(index);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TopicListScreen(lesson_id: item['id'], chapter_name: widget.chapter['chapter_name'])), (route) => true );
                    }
                ),
              );
            },
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
              onPressed: () {
                //...
                showDialog(
                  context: context,
                  builder: (BuildContext context) => alertDialogQuiz(context, 'Add Quiz', widget.topic_id, false),
                );
              },
              heroTag: null,
              label: const Text('Add Quiz'),
              icon: const Icon(
                  Icons.add
              )
          ),
        ],
      ),
    );;
  }
}
