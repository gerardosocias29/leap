import 'package:leap/_screens/createprofile_screen.dart';
import 'package:leap/_screens/loading_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../data_services/user_services.dart';
import '../providers/navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  UserServices user_services = UserServices();
  // List<User>? retrievedUserList;
  late var loggedUser = null;

  Future _initRetrieval() async {
    setState(() {
      isLoading = true;
    });
    /*retrievedUserList = (await user_services.retrieveUsers()).cast<User>();*/
    var user_id = (await AuthService().getUserId());
    loggedUser = (await user_services.retrieveIndividualUser(user_id));
    print(loggedUser);
    print(user_id);
    if(loggedUser == null){
      NavigatorController().pushAndRemoveUntil(context, CreateProfileScreen(), false);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text("Logout"),
            onPressed: () {
              AuthService().signOut().then((value) {
                print("Signed Out");
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignInScreen()), (route) => false );
              });
            },
          ),
          ElevatedButton(
            child: Text("Get Users"),
            onPressed: () {
                _initRetrieval();
            },
          ),
        ]
      ),
    );
  }
