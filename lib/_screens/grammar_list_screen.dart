import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_list_screen.dart';

import '../navbar.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class GrammarListScreen extends StatefulWidget {
  final chapter_id;
  const GrammarListScreen({Key? key, required this.chapter_id}) : super(key: key);

  @override
  State<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends State<GrammarListScreen> {
  late final userDetails;
  late var _isloading = false;
  late final lessonLists;
  final userStorage = StorageProvider().userStorage();
  final commonDataStorage = StorageProvider().commonDataStorage();

  List items = [
    'Noun'
  ];

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

  getLessonLists() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/lessons/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );

    StorageProvider().storageRemoveItem(commonDataStorage, 'lesson_lists');
    StorageProvider().storageAddItem(commonDataStorage, 'lesson_lists', response.body);

    setState(() {

      lessonLists = jsonDecode(StorageProvider().storageGetItem(commonDataStorage, 'lesson_lists'));
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
    getLessonLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Grammar Lessons',
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
        const Center(
          child: CircularProgressIndicator(),
        )
        : Center(
          child: ListView.builder(
            // Let the ListView know how many items it needs to build.
            itemCount: items.length,
            // Provide a builder function. This is where the magic happens.
            // Convert each item into a widget based on the type of item it is.
            itemBuilder: (context, index) {
              final item = lessonLists[index];

              return
                Card(
                  child: ListTile(
                    title: Text("${item['lesson_name']}"),
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
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const TopicListScreen()), (route) => true );
                    }
                  ),
                );
            },
          ),
        ),
      floatingActionButton: userDetails['role_id'] == 0 ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              //...
              showDialog(
                context: context,
                builder: (BuildContext context) => alertDialog(context, 'Add Lesson', 1, false, 'lesson'),
              );
            },
            heroTag: null,
            label: const Text('Add Lessons'),
            icon: const Icon(
              Icons.add
            )
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ) : null,
    );
  }
}

