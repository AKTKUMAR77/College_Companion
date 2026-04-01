import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for fuchsia.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUBB7L2qpv4bqUPhYmU_J07nBH4rT3Q1E',
    appId: '1:116273258135:web:175a847c865c64e45e13d2',
    messagingSenderId: '116273258135',
    projectId: 'college-companion-7b727',
    authDomain: 'college-companion-7b727.firebaseapp.com',
    storageBucket: 'college-companion-7b727.firebasestorage.app',
    measurementId: 'G-0EMFFVXF04',
  );
}
