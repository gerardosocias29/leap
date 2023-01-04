import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leap/_screens/topic_view_screen.dart';

import '../navbar.dart';
import '../providers/storage.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  late final userDetails;
  late var _isloading = false;
  final userStorage = StorageProvider().userStorage();

  List<ListItem> items = [
    HeadingItem('Topics'),
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

  final items_copy = [
    'Topics',
    'Introduction',
    'Types of Noun: Common noun',
    'Proper Noun',
    'Concrete nouns',
    'Abstract nouns',
    'Countable Nouns',
    'Uncountable Nouns',
    'Collective Noun',
    'Compound Nouns',
    'Singular Noun',
    'Plural Noun'
  ];

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
      drawer: _isloading ? null : NavBar(userDetails: userDetails),
      body: Center(
        child: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = items[index];
            final itemCp = items_copy[index];
            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TopicViewScreen(topic_title: itemCp,)), (route) => true );
              }
            );
          },
        ),
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
