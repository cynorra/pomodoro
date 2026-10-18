import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderWebApiKey1234567890',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'cynora-focus',
    authDomain: 'cynora-focus.firebaseapp.com',
    storageBucket: 'cynora-focus.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_JES--dYnPWRGKSZX3OPoH9UqmF2lRo4',
    appId: '1:1089152291243:android:34d65de0d8c1ab6892c2ee',
    messagingSenderId: '1089152291243',
    projectId: 'pomodoro-app-d3068',
    storageBucket: 'pomodoro-app-d3068.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderIosApiKey1234567890',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'cynora-focus',
    storageBucket: 'cynora-focus.appspot.com',
    iosBundleId: 'com.cynora.studycafe.pomodoro',
  );
}
