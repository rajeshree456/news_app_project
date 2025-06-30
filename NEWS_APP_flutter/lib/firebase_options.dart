
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCC6E77S9NlkCgWHOrb7Jw2kNeKc1IN_j0',
    appId: '1:929810998361:web:fd01bb1e641a59300c7d48',
    messagingSenderId: '929810998361',
    projectId: 'rajufinal-755ce',
    authDomain: 'rajufinal-755ce.firebaseapp.com',
    storageBucket: 'rajufinal-755ce.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDaKXA6gfNiMlEuKu_-reBOl2_R12PjgkM',
    appId: '1:929810998361:ios:b09530e189dcf7300c7d48',
    messagingSenderId: '929810998361',
    projectId: 'rajufinal-755ce',
    storageBucket: 'rajufinal-755ce.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCC6E77S9NlkCgWHOrb7Jw2kNeKc1IN_j0',
    appId: '1:929810998361:web:fe5fac4a13f2b99a0c7d48',
    messagingSenderId: '929810998361',
    projectId: 'rajufinal-755ce',
    authDomain: 'rajufinal-755ce.firebaseapp.com',
    storageBucket: 'rajufinal-755ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDh03q05qrDLgwHiJ0QFmX_fC4Op2qiMc8',
    appId: '1:402697999636:ios:18cd1847a7816bbd72de01',
    messagingSenderId: '402697999636',
    projectId: 'rajunewsapp',
    storageBucket: 'rajunewsapp.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIdG8ywAnjqc8ypaGSFS6EaYz5r034Oow',
    appId: '1:402697999636:android:9a7b0712b08cb25972de01',
    messagingSenderId: '402697999636',
    projectId: 'rajunewsapp',
    storageBucket: 'rajunewsapp.firebasestorage.app',
  );

}