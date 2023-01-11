import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/topic_view_screen.dart';

import '../navbar.dart';
import '../providers/storage.dart';
import '../reusable_widgets/reusable_widget.dart';

class TopicListScreen extends StatefulWidget {
  final lesson_id;
  const TopicListScreen({Key? key, required this.lesson_id}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  late final userDetails;
  late var _isloading = false;
  late final topicLists;
  final userStorage = StorageProvider().userStorage();

  List<ListItem> items = [
    MessageItem('Introduction', 'A noun is a word for a person, place, ...'),
    MessageItem('Types of Noun: Common noun', 'Common nouns are words used to name gen...'),
    MessageItem('Proper Noun', 'A noun is a word for a person...'),
    MessageItem('Concrete nouns', 'A noun is a word for a person...'),
    MessageItem('Abstract nouns', 'A noun is a word for a person...'),
    MessageItem('Countable Nouns', 'A noun is a word for a person...'),
    MessageItem('Uncountable Nouns', 'A noun is a word for a person...'),
    MessageItem('Collective Noun', 'A noun is a word for a person...'),
    MessageItem('Compound Nouns', 'A noun is a word for a person...'),
    MessageItem('Singular Noun', 'A noun is a word for a person...'),
    MessageItem('Plural Noun', 'A noun is a word for a person...')
  ];

  final detailed_items = [
    {'title': 'Introduction', 'content' : "A noun is a word for a person, place, thing, or idea. Noun are often used with an article (the, a, an), but  not always start with a capital letter; common nouns do not. Nouns can be singular or plural, concrete or abstract. Nouns show possession by adding's. Nouns can b function in different roles within a sentence; for example, a noun can be a subject, direct object, indirect object, subject complement, or object of a preposition. \n\nNouns are among the most important words in the English language - without them, we'd have a difficult time speaking and writing about anything. There are several different types of English nouns. It is often useful to recognize what type a noun is because different types sometimes have different rules. This helps you to use them correctly."},
    {'title': 'Types of Noun: Common noun', 'content' : 'Content Types of Noun: Common noun'},
    {'title': 'Proper Noun', 'content' : ''},
    {'title': 'Concrete nouns', 'content' : ''},
    {'title': 'Abstract nouns', 'content' : ''},
    {'title': 'Countable Nouns', 'content' : ''},
    {'title': 'Uncountable Nouns', 'content' : ''},
    {'title': 'Collective Noun', 'content' : ''},
    {'title': 'Compound Nouns', 'content' : ''},
    {'title': 'Singular Noun', 'content' : ''},
    {'title': 'Plural Noun', 'content' : ''},
  ];

  late var filteredList;
  getTopicLists() async {
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
    var itm;
    for(itm in res){
      print(itm);
      if (itm['lesson_id'] != null && itm['lesson_id'] == lesson_id) {
        filteredList.add(itm);
      }
    }

    setState(() {
      print(filteredList);
      _isloading = false;
    });
  }

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
    getTopicLists();
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
      const Center(
        child: CircularProgressIndicator(),
      )
      :Center(
        child: RefreshIndicator(
          onRefresh: () async { getTopicLists(); },
          child: ListView.builder(
            // Let the ListView know how many items it needs to build.
            itemCount: filteredList.length,
            // Provide a builder function. This is where the magic happens.
            // Convert each item into a widget based on the type of item it is.
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return Card(
                child: ListTile(
                  title: Text("${item['topic_title']}"),
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TopicViewScreen(topic: item,)), (route) => true );
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) => alertDialog(context, 'Add Topic', widget.lesson_id, false, 'Topic'),
                );
              },
              heroTag: null,
              label: const Text('Add Topic'),
              icon: const Icon(
                  Icons.add
              )
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
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
