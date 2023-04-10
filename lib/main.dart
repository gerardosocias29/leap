import 'dart:isolate';
import 'dart:ui';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leap/_screens/home_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:leap/providers/storage.dart';
import 'package:leap/utils/color_utils.dart';

import 'package:leap/reusable_widgets/reusable_widget.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // your code that you want to run in background
    print('#' * 200);
    print('Executing task');
    print('Task executed: ' + taskName);
    print('inputData::');
    print(inputData);

    return Future.value(true);
  });
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await Firebase.initializeApp().then((value) => { print(StorageProvider().storageGetItem(StorageProvider().userStorage(), 'user_id')), print("value") });
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lema',
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
        primaryColor: hexStringToColor('#09c1ca'),
        primaryColorLight: hexStringToColor('#b5e9f9')
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var userDetails;
  Future _initRetrieval() async {
    return await StorageProvider().storageGetItem( await StorageProvider().userStorage(), 'user_id');
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      userDetails = _initRetrieval();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Image.asset('assets/logo.png', height: 200, width: 200)
        ],
      ),
      // ignore: unnecessary_null_comparison
      nextScreen: ( userDetails == null) ? const SignInScreen() : const HomeScreen(),
      splashIconSize: 200,
      splashTransition: SplashTransition.fadeTransition
    );
  }
}
