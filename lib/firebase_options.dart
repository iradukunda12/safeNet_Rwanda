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
    apiKey: 'AIzaSyCxJBEj1hypEm0ljwOfntrml1SF8PfszuA',
    appId: '1:447274015939:web:9160d1b595822a4faad676',
    messagingSenderId: '447274015939',
    projectId: 'schoolmanagement-556ae',
    authDomain: 'schoolmanagement-556ae.firebaseapp.com',
    storageBucket: 'schoolmanagement-556ae.firebasestorage.app',
    measurementId: 'G-J37NP47SCV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAx7a7GB6XP32v1ji8H4aqs9NUESTWv4Xo',
    appId: '1:447274015939:android:68bd8547132bf97aaad676',
    messagingSenderId: '447274015939',
    projectId: 'schoolmanagement-556ae',
    storageBucket: 'schoolmanagement-556ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAE1j3L4mGfPt0kl6K7bQpq6OrBJkt6oNM',
    appId: '1:447274015939:ios:44682a199c8c1ab1aad676',
    messagingSenderId: '447274015939',
    projectId: 'schoolmanagement-556ae',
    storageBucket: 'schoolmanagement-556ae.firebasestorage.app',
    iosBundleId: 'com.example.schoolProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAE1j3L4mGfPt0kl6K7bQpq6OrBJkt6oNM',
    appId: '1:447274015939:ios:44682a199c8c1ab1aad676',
    messagingSenderId: '447274015939',
    projectId: 'schoolmanagement-556ae',
    storageBucket: 'schoolmanagement-556ae.firebasestorage.app',
    iosBundleId: 'com.example.schoolProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCxJBEj1hypEm0ljwOfntrml1SF8PfszuA',
    appId: '1:447274015939:web:43b360180aff8eaaaad676',
    messagingSenderId: '447274015939',
    projectId: 'schoolmanagement-556ae',
    authDomain: 'schoolmanagement-556ae.firebaseapp.com',
    storageBucket: 'schoolmanagement-556ae.firebasestorage.app',
    measurementId: 'G-TYFSN390PX',
  );
}
