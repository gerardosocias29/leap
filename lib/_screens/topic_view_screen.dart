import 'dart:convert';

import 'package:flutter/material.dart';

import '../navbar.dart';
import '../providers/storage.dart';

class TopicViewScreen extends StatefulWidget {
  final topic_title;
  const TopicViewScreen({Key? key, required this.topic_title}) : super(key: key);

  @override
  State<TopicViewScreen> createState() => _TopicViewScreenState();
}

class _TopicViewScreenState extends State<TopicViewScreen> {
  late final userDetails;
  late var _isloading = false;
  final userStorage = StorageProvider().userStorage();

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
        child: Text("${widget.topic_title}"),
      ),
    );
  }
}