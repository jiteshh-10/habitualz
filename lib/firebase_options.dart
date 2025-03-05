// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAuLs9fsAmSUPMKwkL0JglTajlLrdXWXCk',
    appId: '1:1011121683672:web:4043b496f999ba98056bad',
    messagingSenderId: '1011121683672',
    projectId: 'habitualz-531f2',
    authDomain: 'habitualz-531f2.firebaseapp.com',
    storageBucket: 'habitualz-531f2.firebasestorage.app',
    measurementId: 'G-MP6VKMQNK4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgf2WAIOG5grJKFsGP_MuxvU_BxZk5lls',
    appId: '1:1011121683672:android:cf6590a1cc7ab0e8056bad',
    messagingSenderId: '1011121683672',
    projectId: 'habitualz-531f2',
    storageBucket: 'habitualz-531f2.firebasestorage.app',
  );
}
