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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBsjygDk4lLv1NSKG-r0yAyEgy3R9M-n4M',
    appId: '1:386091954658:web:d4f0f3e88e4e2961fd89bb',
    messagingSenderId: '386091954658',
    projectId: 'kaadu-wishlist',
    authDomain: 'kaadu-wishlist.firebaseapp.com',
    storageBucket: 'kaadu-wishlist.firebasestorage.app',
    measurementId: 'G-71SHJYEQPC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqYeG1nCYnu_rvcalKt9IVPSoSvOY90lk',
    appId: '1:386091954658:android:cc26afc891c0bea0fd89bb',
    messagingSenderId: '386091954658',
    projectId: 'kaadu-wishlist',
    storageBucket: 'kaadu-wishlist.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9uK3ozqN_THrB76yYgCXSfzegODcqNnE',
    appId: '1:386091954658:ios:18e35f0e7c9816c3fd89bb',
    messagingSenderId: '386091954658',
    projectId: 'kaadu-wishlist',
    storageBucket: 'kaadu-wishlist.firebasestorage.app',
    iosBundleId: 'com.example.kaaduOrganicsApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB9uK3ozqN_THrB76yYgCXSfzegODcqNnE',
    appId: '1:386091954658:ios:18e35f0e7c9816c3fd89bb',
    messagingSenderId: '386091954658',
    projectId: 'kaadu-wishlist',
    storageBucket: 'kaadu-wishlist.firebasestorage.app',
    iosBundleId: 'com.example.kaaduOrganicsApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBsjygDk4lLv1NSKG-r0yAyEgy3R9M-n4M',
    appId: '1:386091954658:web:29cb17b6aa0ab842fd89bb',
    messagingSenderId: '386091954658',
    projectId: 'kaadu-wishlist',
    authDomain: 'kaadu-wishlist.firebaseapp.com',
    storageBucket: 'kaadu-wishlist.firebasestorage.app',
    measurementId: 'G-L1CWMMHWY4',
  );

}