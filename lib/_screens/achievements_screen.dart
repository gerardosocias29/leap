import 'package:flutter/material.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {

  late var lessonLists;
  late bool _isloading = false;
  late var achievements = [
    { 'image': 'assets/leaderboards_image/bonafide_lemaster.png', 'title': 'Bonafide Lemaster', 'progress': 0.1, 'details': 'You need to finish LEMA', 'isunlocked' : false },
    { 'image': 'assets/leaderboards_image/champion.png', 'title': 'Champion', 'progress': 0.3, 'details': '100% on all quizzes', 'isunlocked' : false },
    { 'image': 'assets/leaderboards_image/dedicated_youngster.png', 'title': 'Dedicated Youngster', 'progress': 0.7, 'details': 'Perfect 50% of all quizzes', 'isunlocked' : false }
  ];

  Future _initRetrieval() async {
    setState(() {
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
      const Center(
        child: CircularProgressIndicator(),
      ) : Center(
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
                        image: AssetImage('${achievement['image']}')
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: (achievement['isunlocked'] == false) ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${achievement['title']}', style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 30),),
                          Text('${achievement['details']}', style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 15),),
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


/* ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              var achievement = achievements[index];
              return ListTile(
                leading: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('${achievement['image']}')
                ),
                title: Text('${achievement['title']}'),
                subtitle: Column(
                  children: [
                    LinearProgressIndicator(
                      value: achievement['progress'] as double,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    Text("${(achievement['progress'] as double) * 100}% completed"),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          ),*/