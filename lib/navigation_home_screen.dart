import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leap/_screens/credits_screen.dart';
import 'package:leap/_screens/home_screen.dart';
import 'package:leap/_screens/leaderboard_screen.dart';
import 'package:leap/_screens/settings_screen.dart';
import 'package:leap/_screens/user_list_screen.dart';
import 'package:leap/providers/storage.dart';

import '_screens/achievements_screen.dart';
import '_screens/createprofile_screen.dart';
import '_screens/signin_screen.dart';
import 'api.dart';
import 'app_theme.dart';
import 'custom_drawer/drawer_user_controller.dart';
import 'custom_drawer/home_drawer.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;
  final userStorage = StorageProvider().userStorage();
  late var _isloading = false;
  late var userDetails = {};

  Future _initRetrieval() async {
    var userId = await StorageProvider().storageGetItem(userStorage, 'user_id');
    setState(() {
      _isloading = true;
    });
    setUserDetails(await Api().getRequest('users/$userId'));
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
      setGlobalUserDetails(details);
    });
  }

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const HomeScreen();
    super.initState();
    _initRetrieval();
  }

  bool _isDoubleTapped = false;
  late Timer _backButtonTimer;

  @override
  void dispose() {
    _backButtonTimer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isDoubleTapped) {
      return true;
    } else {
      _isDoubleTapped = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      _backButtonTimer = Timer(const Duration(seconds: 2), () {
        _isDoubleTapped = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: AppTheme.nearlyWhite,
            body: DrawerUserController(
              screenIndex: drawerIndex,
              drawerWidth: MediaQuery.of(context).size.width * 0.75,
              onDrawerCall: (DrawerIndex drawerIndexdata) {
                changeIndex(drawerIndexdata);
                //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
              },
              screenView: screenView,
              //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
            ),
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const HomeScreen();
          });
          break;
        case DrawerIndex.Profile:
          setState(() {
            screenView = CreateProfileScreen(userDetails: userDetails);
          });
          break;
        case DrawerIndex.Achievements:
          setState(() {
            screenView = const AchievementScreen();
          });
          break;
        case DrawerIndex.Leaderboard:
          setState(() {
            screenView = const LeaderboardScreen();
          });
          break;
        case DrawerIndex.Userlists:
          setState(() {
            screenView = const UserListScreen();
          });
          break;
        case DrawerIndex.Settings:
          setState(() {
            screenView = const SettingsScreen();
          });
          break;
        case DrawerIndex.Credits:
          setState(() {
            screenView = CreditsScreen();
          });
          break;
        default:
          break;
      }
    }
  }
}
late Map globalUserDetails = {};
getGlobalUserDetails() {
  return globalUserDetails;
}
setGlobalUserDetails(userDetails) {
  globalUserDetails = userDetails;
}