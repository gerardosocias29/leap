import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:leap/_screens/grammar_list_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
import 'package:leap/api.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  double marginHorizontal = 16.0;

  UserServices user_services = UserServices();
  final userStorage = StorageProvider().userStorage();
  final commonDataStorage = StorageProvider().commonDataStorage();
  late final user_id;

  late var userDetails = {};
  late var chapterLists = [];
  late var topicLists = [];
  late var leaderboardsLists = [];
  late var topicWithScore = [];
  late var _isloading = false;
  late var overallScore = 0;
  late double grammar_percentage = 0.0;
  late var total_users = 0;
  late double lessons_overall_percentage = 0.0;

  calcPercentage() {
    var percentage = (topicWithScore.length / topicLists.length);
    grammar_percentage = percentage;
  }

  calculateLessonsUsage(data) {
    double perc = 0.0;
    double overall_perc = 0.0;
    for(var user in data){
      perc += user['topics_done'] / topicLists.length;
    }
    overall_perc = perc / total_users;
    setState(() {
      lessons_overall_percentage = overall_perc;
    });
  }

  getData() async {
    setState(() {
      grammar_percentage = 0;
      overallScore = 0;
      total_users = 0;
    });
    var urls = [
      'chapters/all', // 0
      'topics/all', // 1
      'user_topics_detailed/${userDetails['id']}', // 2
      'users_count', // 3
      'users_with_topics_done', // 4
      'leaderboards_lists/3' // 5
    ];
    var datas = await Api().multipleGetRequest(urls);

    setState(() {
      setChapterList(datas[0]);
      setTopicList(datas[1]);
      setTopicWithScore(datas[2]);
      calcPercentage();

      total_users = datas[3]['users_count'] ?? 0;
      calculateLessonsUsage(datas[4]);
      leaderboardsLists = datas[5];
      _isloading = false;
    });
  }

  setUserDetails(details) async {
    if(details == null || details == []){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false );
    } else {
      await StorageProvider().storageRemoveItem(userStorage, 'user_details');
      await StorageProvider().storageAddItem(userStorage, 'user_details', jsonEncode(details));
    }

    setState(() {
      userDetails = details;
      getData();
    });
  }

  setChapterList(chapters) {
    chapterLists = chapters;
  }

  setTopicList(topics) {
    topicLists = topics;
  }

  setTopicWithScore(topicWithScores) {
    var mytopics = [];
    var scores = 0;
    for(var topic in topicWithScores){
      if(topic['user_id'] == userDetails['id']){
        mytopics.add(topic);
        var sc = topic['score'];
        scores = scores + sc as int;
      }
    }
    topicWithScore = mytopics;
    overallScore = scores;
  }

  Future _initRetrieval() async {
    user_id = await StorageProvider().storageGetItem(userStorage, 'user_id');
    setState(() {
      _isloading = true;
    });
    setUserDetails(await Api().getRequest('users/$user_id'));
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
          onRefresh: () => getData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                ( userDetails['role_id'] != 0) ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 4.0, 16.0),
                      child: Container(
                        height: 140.0,
                        width: MediaQuery.of(context).size.width / 2.3,
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
                        child: CircularPercentIndicator(
                          radius:50.0,
                          lineWidth: 5.0,
                          percent: grammar_percentage,
                          animation: true,
                          center: Text("${(grammar_percentage * 100).toStringAsFixed(0)}%\nCompleted", textAlign: TextAlign.center),
                          progressColor: Colors.green,
                          footer: const Text(
                            "All Topics",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 16.0),
                      child: Container(
                        height: 140.0,
                        width: MediaQuery.of(context).size.width / 2.3,
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
                        child: CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 5.0,
                          percent: (overallScore / overallScore),
                          animation: true,
                          center: Text("$overallScore", textAlign: TextAlign.center),
                          progressColor: Colors.green,
                          footer: const Text(
                            "Overall Score",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    ),
                  ],
                ) : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 4.0, 16.0),
                      child: Container(
                        height: 140.0,
                        width: MediaQuery.of(context).size.width / 2.3,
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
                        child: CircularPercentIndicator(
                          radius:50.0,
                          lineWidth: 5.0,
                          percent: total_users/total_users,
                          animation: true,
                          center: Text("$total_users", textAlign: TextAlign.center),
                          progressColor: Colors.green,
                          footer: const Text(
                            "Total Users",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 16.0),
                      child: Container(
                        height: 140.0,
                        width: MediaQuery.of(context).size.width / 2.3,
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
                        child: CircularPercentIndicator(
                          radius: 50.0,
                          lineWidth: 5.0,
                          percent: lessons_overall_percentage,
                          animation: true,
                          center: Text("${(lessons_overall_percentage * 100).toStringAsFixed(0)}%", textAlign: TextAlign.center),
                          progressColor: Colors.green,
                          footer: const Text(
                            "Lessons Usage",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ),
                    ),
                  ],
                ) ,
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
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: chapterLists.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      print('printing list index');
                      print(chapterLists[index]);
                      return CourseCard(chapterLists[index]);
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
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: leaderboardsLists.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return LeaderBoard(index.toInt(), leaderboardsLists[index]);
                          },
                        ),

                      ),
                    ]
                  )
                ),
              ],
            )
          ),
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
              children: const <Widget>[
                Center(child: Icon(FontAwesomeIcons.crown, size: 36, color: Colors.grey,)),
                Padding(
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
                          radius: 30,
                          child: Text('${leaderboard['first_name'].substring(0,1)}${leaderboard['last_name'].substring(0,1)}'.toUpperCase()),
                        ),
                      ),

                      Align(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 5),
                                child: Text(leaderboard['first_name'], style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
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
                    image: AssetImage('${list['photo_url']}'), fit: BoxFit.cover
                  ),
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
                '${list['chapter_name']}',
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
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => GrammarListScreen(chapter: list)), (route) => true );
      },
    );
  }
}