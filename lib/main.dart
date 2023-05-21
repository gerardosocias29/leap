import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leap/_screens/home_screen.dart';
import 'package:leap/_screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:leap/providers/storage.dart';
import 'package:leap/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'introduction_animation/introduction_animation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) => { print(StorageProvider().storageGetItem(StorageProvider().userStorage(), 'user_id')), print("value") });
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));
}

Future<bool> isFirstAppLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
  if (isFirstLaunch) {
    await prefs.setBool('first_launch', false);
  }
  return isFirstLaunch;
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
      !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return FutureBuilder<bool>(
      future: isFirstAppLaunch(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        print("snapshot:: $snapshot");
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator or splash screen
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else {
          bool isFirstLaunch = snapshot.data!;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lema',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xff132137),
              primaryColorLight: hexStringToColor('#b5e9f9'),
              textTheme: AppTheme.textTheme,
              platform: TargetPlatform.iOS,
            ),
            home: isFirstLaunch ? IntroductionAnimationScreen() : SplashScreen(),
          );
        }
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lema',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xff132137),
        primaryColorLight: hexStringToColor('#b5e9f9'),
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: const IntroductionAnimationScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
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
      nextScreen: ( userDetails != null ) ? const SignInScreen() : const HomeScreen(),
      splashIconSize: 200,
      splashTransition: SplashTransition.fadeTransition
    );
  }
}
