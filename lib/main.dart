import 'package:firebase_core/firebase_core.dart';
import 'package:leap/_screens/createprofile_screen.dart';
import 'package:leap/_screens/home_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:leap/auth_service.dart';
import 'package:leap/data_services/user_services.dart';
import 'package:leap/utils/color_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
  
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leap',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        primaryColor: hexStringToColor('#4E0189')
      ),
      home: (AuthService().getCurrentUser() == null ) ? SignInScreen() : HomeScreen(),
    );
  }
}