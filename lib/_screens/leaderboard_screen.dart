import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api.dart';
import '../providers/storage.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late var leaderboardLists;
  late var _isloading = false;
  late var userDetails;
  final userStorage = StorageProvider().userStorage();
  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var userdetail = jsonDecode(await StorageProvider().storageGetItem(userStorage, 'user_details'));
    var urls = [
      'leaderboards_lists/all'
    ];
    var datas = await Api().multipleGetRequest(urls);

    setState(() {
      _isloading = false;
      leaderboardLists = datas[0];
      userDetails = userdetail;
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
          'Leaderboards',
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
      ) : Container(
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
            itemCount: leaderboardLists.length,
            itemBuilder: (context, index) {
              final item = leaderboardLists[index];
              return Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: (userDetails['id'] == item['id']) ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                elevation: (userDetails['id'] == item['id']) ? 5 : 1,
                child: ListTile(
                  title: (userDetails['id'] == item['id']) ? const Text('You') : Text("${item['first_name']} ${item['last_name']}"),
                  trailing: Text("${item['score']}"),
                  leading: (index < 3) ? Icon(FontAwesomeIcons.medal, color: (index == 0) ? Colors.yellow : ((index == 1) ? Colors.grey : Colors.orange[300]),) :
                    SizedBox(child: Text((index + 1).toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.left,)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
