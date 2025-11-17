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
/// 
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
    apiKey: 'AIzaSyC4TuPH51vutK5zSbaghpsd6pomysvwi8Y',
    appId: '1:941092287032:web:b5d4d63851bdb21cc0accd',
    messagingSenderId: '941092287032',
    projectId: 'fyp-authentication-c90d3',
    authDomain: 'fyp-authentication-c90d3.firebaseapp.com',
    storageBucket: 'fyp-authentication-c90d3.firebasestorage.app',
    measurementId: 'G-EGGSBGQ8KM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgQvlOgFlFf-XL2l7pua55BoR6iDYjQ8k',
    appId: '1:941092287032:android:18cd0af9a5447cb9c0accd',
    messagingSenderId: '941092287032',
    projectId: 'fyp-authentication-c90d3',
    storageBucket: 'fyp-authentication-c90d3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBO71UXMMqv9SJ4GIDCbqKyVMHfKJTWDZM',
    appId: '1:941092287032:ios:6305859d643bc1c9c0accd',
    messagingSenderId: '941092287032',
    projectId: 'fyp-authentication-c90d3',
    storageBucket: 'fyp-authentication-c90d3.firebasestorage.app',
    iosBundleId: 'com.example.projectFyp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBO71UXMMqv9SJ4GIDCbqKyVMHfKJTWDZM',
    appId: '1:941092287032:ios:6305859d643bc1c9c0accd',
    messagingSenderId: '941092287032',
    projectId: 'fyp-authentication-c90d3',
    storageBucket: 'fyp-authentication-c90d3.firebasestorage.app',
    iosBundleId: 'com.example.projectFyp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC4TuPH51vutK5zSbaghpsd6pomysvwi8Y',
    appId: '1:941092287032:web:9918934213555128c0accd',
    messagingSenderId: '941092287032',
    projectId: 'fyp-authentication-c90d3',
    authDomain: 'fyp-authentication-c90d3.firebaseapp.com',
    storageBucket: 'fyp-authentication-c90d3.firebasestorage.app',
    measurementId: 'G-3L48J7ZJYV',
  );
}
