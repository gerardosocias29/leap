import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_view_screen.dart';

import '../api.dart';
import '../navbar.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class TopicListScreen extends StatefulWidget {
  final lesson_id;
  final chapter_name;
  const TopicListScreen({Key? key, required this.lesson_id, required this.chapter_name}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  late final userDetails;
  late var _isloading = false;
  late final topicLists;
  final userStorage = StorageProvider().userStorage();

  late var filteredList;
  getTopicLists() async {
    setState(() {
      _isloading = true;
    });
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/topics/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );

    var res = jsonDecode(response.body);
    filteredList = [];
    var lesson_id = widget.lesson_id;
    for(var itm in res){
      if (itm['lesson_id'] != null && itm['lesson_id'] == lesson_id) {
        filteredList.add(itm);
      }
    }

    setState(() {
      _isloading = false;
    });
  }

  Future _initRetrieval() async {
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
      getTopicLists();
    });
  }

  Future _topicDeletion(id) async {
    var response = await Api().deleteRequest('topics/delete/$id');
    if(response['status']){
      getTopicLists();
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
          'Topics',
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
      : Container(
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
          onRefresh: () async { getTopicLists(); },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            // Let the ListView know how many items it needs to build.
            itemCount: filteredList.length,
            // Provide a builder function. This is where the magic happens.
            // Convert each item into a widget based on the type of item it is.
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return Card(
                child: ListTile(
                  title: Text("${item['topic_title']}"),
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
                            builder: (BuildContext context) => alertDialog(context, 'Update Topic', widget.lesson_id, false, 'update_topic', getTopicLists, item),
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
                          showDeleteConfirmationDialog(context, () => { _topicDeletion(item['id']) });
                        },
                      ),
                    ],
                  ) : null,
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TopicViewScreen(topic: item, chapter_name: widget.chapter_name)), (route) => true );
                  }
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: userDetails['role_id'] == 0 ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => alertDialog(context, 'Add Topic', widget.lesson_id, false, 'Topic', getTopicLists),
                );
              },
              heroTag: null,
              label: const Text('Add Topic'),
              icon: const Icon(
                  Icons.add
              )
          ),
        ],
      ) : null,
    );
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
