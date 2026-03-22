// File generated manually based on Firebase Console config
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return android; // Fallback to Android config for development
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKlh8r9g2gBYEAyEb18vvG_C0_hh2B8Nc',
    appId: '1:673238034109:android:1b6705bf92653cdce7b9d4',
    messagingSenderId: '673238034109',
    projectId: 'bloomfit-levelup',
    storageBucket: 'bloomfit-levelup.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzlLbo2dz58g9Yw0aW4E0asAqNPZ_RV1A',
    appId: '1:673238034109:ios:5e662cedf05cca41e7b9d4',
    messagingSenderId: '673238034109',
    projectId: 'bloomfit-levelup',
    storageBucket: 'bloomfit-levelup.firebasestorage.app',
    iosBundleId: 'com.bloomfit.bloomfit',
  );
}
