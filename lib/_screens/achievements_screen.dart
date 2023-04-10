import 'dart:convert';

import 'package:flutter/material.dart';

import '../api.dart';
import '../providers/storage.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {

  late var lessonLists;
  late bool _isloading = false;
  late var achievements = [];
  late var userDetails;
  final userStorage = StorageProvider().userStorage();
  Future _initRetrieval() async {
    setState(() {
      _isloading = false;
    });
    var userdetail = jsonDecode(await StorageProvider().storageGetItem(userStorage, 'user_details'));

    print("userdetail:: $userdetail");
    var urls = [
      'achievements/list/${userdetail["id"]}'
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      achievements = datas[0];
      print(achievements);
      userDetails = userdetail;
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
          'Achievements',
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
            scrollDirection: Axis.vertical,
            itemCount: achievements.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var achievement = achievements[index];
              return SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width * 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                        image: AssetImage('${achievement['image_url']}')
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: (achievement['isunlocked'] == null || achievement['isunlocked'] == false ) ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${achievement['achievement_name']}', style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 30),),
                          Text('${achievement['achievement_details']}', style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 15),),
                          const Icon(Icons.lock_outlined, size: 50,)
                        ],
                      ) : null,
                    ),
                  ),
                )
              );
            }
          ),
        )
      ),
    );
  }
}