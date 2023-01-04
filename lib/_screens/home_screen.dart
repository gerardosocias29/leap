import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:leap/_screens/grammar_list_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
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
    { 'title': 'Grammar', 'topics': 20, 'image': 'assets/grammar.png',},
    { 'title': 'Speech', 'topics': 20, 'image': 'assets/pronunciation.jpg',}
  ];

  List<Object> leaderBoardItems = [
    {'name': 'Me', 'score': 1000, 'icon': Icons.home},
    {'name': 'Myself', 'score': 900, 'icon': Icons.home},
    {'name': 'I', 'score': 700, 'icon': Icons.home},
  ];

  getUserDetails(user_id) async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    print("backendUrl::$backendUrl/api/users");
    final uri = Uri.parse("$backendUrl/api/users/$user_id");
    final headers = {'content-type': 'application/json'};

    Response response = await get(
        uri,
        headers: headers
    );

    int statusCode = response.statusCode;
    print("statusCode::$statusCode");

    if(statusCode == 404 || statusCode == 500){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false );
    } else {
      StorageProvider().storageRemoveItem(userStorage, 'user_details');
      StorageProvider().storageAddItem(userStorage, 'user_details', response.body);
      setState(() {
        _isloading = false;
      });
    }
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });

  }

  Future _initRetrieval() async {
    setState(() {
      _isloading = true;
    });
    var user_id = StorageProvider().storageGetItem(userStorage, 'user_id');
    getUserDetails(user_id);
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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Insights",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 1.9,
                    fontWeight: FontWeight.w700),
                )
              ),
              const SizedBox(
                height: 30,
              ),

              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Lessons",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 1.9,
                    fontWeight: FontWeight.w700),
                )
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

              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Leaderboards",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 1.9,
                    fontWeight: FontWeight.w700),
                )
              ),

              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 15.0,
                            offset: Offset(0.75, 0.95))
                        ],
                        color: Colors.white
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: leaderBoardItems.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          print('printing list index');
                          print(leaderBoardItems[index]);
                          return LeaderBoard(index.toInt(), leaderBoardItems[index]);
                        },
                      ),

                    ),
                  ]
                )
              ),
            ],
          )
        )
      )
  );
}

class LeaderBoard extends StatelessWidget {
  final int index;
  final leaderboard;

  const LeaderBoard(
    this.index, this.leaderboard, {super.key}
  );

  @override
  Widget build(BuildContext context) {
    int ind = index + 1;
    Widget crown;
    crown = (ind == 1) ? Padding(
        padding: const EdgeInsets.only(right: 0.0),
        child: Stack(
          alignment: Alignment.center,
          children: const <Widget>[
            Center(child: Icon(FontAwesomeIcons.crown, size: 36, color: Colors.yellow,)),
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 6),
              child: Center(child: Text('1', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)),
            )
          ],
        )
    ) : ((ind == 2) ? Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Center(child: Icon(FontAwesomeIcons.crown, size: 36, color: Colors.grey[300],)),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 6),
                  child: Center(child: Text('2', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)),
                )
              ],
            )
        ) : ((ind == 3) ? Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Center(child: Icon(FontAwesomeIcons.crown, size: 36, color: Colors.orange[300],)),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 6),
                      child: Center(child: Text('3', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)),
                    )
                  ],
                )
            ) : CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 13,
              child: Text(
                ind.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),)
            )) );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            boxShadow: [BoxShadow(color: Colors.black26,blurRadius: 5.0)]
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: Row(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 25),
                          child: crown,
                        ),
                      ),

                      Align(
                        child: CircleAvatar(
                          backgroundColor: Colors.red.shade800,
                          child: Text('GI'),
                          radius: 30,
                        ),
                      ),

                      Align(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 5),
                                child: Text(leaderboard['name'], style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${leaderboard['score']}', style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final list;

  const CourseCard(
    this.list, {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child:
        Padding(
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
                  color: Colors.white),
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
      ),
      onTap: () {
        if(list['title'] == "Grammar"){
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const GrammarListScreen()), (route) => true );
        } else {
          // Pronunciation Screen
        }
      },
    );
  }
}