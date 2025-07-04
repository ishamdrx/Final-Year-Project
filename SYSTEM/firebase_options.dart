// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.rr
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
          'DefaultFirebaseOptions have not been configured for iOS. '
              'Run the FlutterFire CLI again to set up Firebase for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS. '
              'Run the FlutterFire CLI again to set up Firebase for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows. '
              'Run the FlutterFire CLI again to set up Firebase for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux. '
              'Run the FlutterFire CLI again to set up Firebase for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'xxx',
    appId: 'xxx',
    messagingSenderId: 'xxx',
    projectId: 'xxx',
    authDomain: 'xxx',
    storageBucket: 'xxx',
    measurementId: 'xxx',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'xxx',
    appId: 'xxx',
    messagingSenderId: 'xxx',
    projectId: 'xxx',
    storageBucket: 'xxx',
  );

}
