// File generated from android/app/google-services.json
// Project: bl-real-estate (1072318429261)
// Package: com.blrealestateapp.blrealestate
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Sourced from android/app/google-services.json
  // client[2] → package: com.blrealestateapp.blrealestate
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8WIxcZcsWQfhdWLu7dRc77gUppmc2ydE',
    appId: '1:1072318429261:android:b3f6d5e64486933cd50404',
    messagingSenderId: '1072318429261',
    projectId: 'bl-real-estate',
    storageBucket: 'bl-real-estate.firebasestorage.app',
  );

  // Web placeholder — not used by Android build
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8WIxcZcsWQfhdWLu7dRc77gUppmc2ydE',
    appId: '1:1072318429261:web:000000000000000000000000',
    messagingSenderId: '1072318429261',
    projectId: 'bl-real-estate',
    storageBucket: 'bl-real-estate.firebasestorage.app',
  );
}
