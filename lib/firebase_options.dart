// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAo-sp-B3K1b8xLAHfxuUzo7qBnFb2s6cs',
    appId: '1:278686566343:web:838f27ff95a08700197be2',
    messagingSenderId: '278686566343',
    projectId: 'lema-99ee9',
    authDomain: 'lema-99ee9.firebaseapp.com',
    storageBucket: 'lema-99ee9.appspot.com',
    measurementId: 'G-KKL5EWNV3B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgEFiRtjfzdtAJxMoOqsGLgVAhifdImow',
    appId: '1:278686566343:android:647e97399c899a34197be2',
    messagingSenderId: '278686566343',
    projectId: 'lema-99ee9',
    storageBucket: 'lema-99ee9.appspot.com',
  );
}
