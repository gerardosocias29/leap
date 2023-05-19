import 'package:flutter/material.dart';

import '../api.dart';

class AchievementUsersScreen extends StatefulWidget {
  final achievement_id;
  final achievement_title;
  const AchievementUsersScreen({Key? key, required this.achievement_id, required this.achievement_title}) : super(key: key);

  @override
  State<AchievementUsersScreen> createState() => _AchievementUsersScreenState();
}

class _AchievementUsersScreenState extends State<AchievementUsersScreen> {
  late bool _isloading = false;
  late var users = [];
  Future _initRetrieval() async {
    setState(() {
      _isloading = false;
    });
    var urls = [
      'achievement-with-user-lists/${widget.achievement_id}'
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      users = datas[0];
      print('${widget.achievement_id} $users');
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
          'Users Who Got ${widget.achievement_title}',
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
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )
      :
      (users.isNotEmpty) ? Container(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (BuildContext context, index) {
            final item = users[index];
            return ListTile(
                title: Text("${item['first_name']} ${item['last_name']}"),
                onTap: () {
                }
            );
          }
        ),
      )
      : const Center(
        child: Text(
          'No Data To Display',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    );
  }
}
