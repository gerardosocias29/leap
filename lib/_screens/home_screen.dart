import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../data_services/user_services.dart';
import '../navbar.dart';
import '../providers/navigator.dart';
import '../providers/storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double marginHorizontal = 16.0;

  UserServices user_services = UserServices();
  final userStorage = StorageProvider().userStorage();
  late final userDetails;
  late var _isloading = false;
  List<Object> lists = [
    { 'title': 'Grammar and Vocabulary', 'topics': 20, 'image': 'assets/logo.png',},
    { 'title': 'Speech', 'topics': 20, 'image': 'assets/logo.png',}
  ];
  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var user_id = StorageProvider().storageGetItem(userStorage, 'user_id');
    var loggedUser = (await user_services.retrieveIndividualUser(user_id));
    if(loggedUser == null){
      NavigatorController().pushAndRemoveUntil(context, CreateProfileScreen(), false);
    } else {
      StorageProvider().storageRemoveItem(userStorage, 'user_details');
      StorageProvider().storageAddItem(userStorage, 'user_details', loggedUser);
      setState(() {
        _isloading = false;
      });
    }
    setState(() {
      userDetails = StorageProvider().storageGetItem(userStorage, 'user_details');
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        'LEMA',
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
    body: _isloading ?
      const Center(
        child: CircularProgressIndicator(),
      )
      :
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.4, 0.8, 0.5],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Lessons",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        letterSpacing: 1.9,
                        fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        letterSpacing: 1.9,
                        fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Container(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lists.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    print('printing list index');
                    print(lists[index]);
                    return CourseCard(lists[index]);
                  },
                ),
              ),
            ],
          )
        )
      )
    );
  }

class CourseCard extends StatelessWidget {
  final list;

  const CourseCard(
    this.list, {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 140.0,
            width: 250.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('${list['image']}'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 15.0,
                      offset: Offset(0.75, 0.95))
                ],
                color: Colors.grey),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '${list['title']}',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.9,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}