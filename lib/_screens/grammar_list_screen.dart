import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_list_screen.dart';

import '../api.dart';
import '../app_theme.dart';
import '../navbar.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class GrammarListScreen extends StatefulWidget {
  final chapter;
  const GrammarListScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends State<GrammarListScreen> {
  late var userDetails = {};
  late bool _isloading = false;
  late var lessonLists;
  final userStorage = StorageProvider().userStorage();

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var urls = [
      'lessons_list/${widget.chapter['id']}', // 0
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
      lessonLists = datas[0];
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isloading = false;
    });
  }

  Future _lessonDeletion(id) async {
    var response = await Api().deleteRequest('lessons/delete/$id');
    if(response['status']){
      _initRetrieval();
    }
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
          '${widget.chapter['chapter_name']} Lessons',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: AppTheme.beige,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: _isloading ?
        Container(
          color: AppTheme.beige,
          child:
          const Center(
            child: CircularProgressIndicator(),
          )
        )
        : Container(
          color: AppTheme.beige,
          child: RefreshIndicator(
            onRefresh: () async { _initRetrieval(); },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: lessonLists.length,
              itemBuilder: (context, index) {
                final item = lessonLists[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,// Add animation to the bottom padding
                  ),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: AppTheme.teal
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text("${item['lesson_name']}"),

                        trailing: userDetails['role_id'] == 0 ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20.0,
                                // color: Colors.black,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => alertDialog(context, 'Update Lesson', widget.chapter['id'], false, 'update_lesson', _initRetrieval, item),
                                  // alertDialog(context, 'Add Lesson', widget.chapter['id'], false, 'Lesson')
                                );
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
                                showDeleteConfirmationDialog(context, () => { _lessonDeletion(item['id']) });
                              },
                            ),
                          ],
                        ) : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const<Widget>[
                            Icon(
                              Icons.chevron_right_outlined,
                              size: 20,
                              color: AppTheme.teal,
                            )
                          ]
                        ),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TopicListScreen(lesson_id: item['id'], chapter_name: widget.chapter['chapter_name'])), (route) => true );
                      }
                    ),
                  ),
                );
              },
            ),
          ),
        ),

      // (role_id == 1) ? //true : //false

      floatingActionButton: userDetails['role_id'] == 0 ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              //...
              showDialog(
                context: context,
                builder: (BuildContext context) => alertDialog(context, 'Add Lesson', widget.chapter['id'], false, 'Lesson', _initRetrieval),
              );
            },
            heroTag: null,
            label: const Text('Add Lessons'),
            icon: const Icon(
              Icons.add
            )
          ),
        ],
      ) : null,
    );
  }
}

