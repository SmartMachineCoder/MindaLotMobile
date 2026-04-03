// IMPORTANT: This file is a placeholder.
//
// To configure Firebase for this project:
// 1. Go to https://console.firebase.google.com
// 2. Create a new project named "mindalot"
// 3. Add Android app with package: com.migs.mindalot
// 4. Add iOS app with bundle ID: com.migs.mindalot
// 5. Run: flutterfire configure
//    This auto-generates this file with your real credentials.
//
// Until then, the app runs in POC mode (local state only, no Firebase).

// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Replace these placeholder values with your real Firebase config ──
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_YOUR_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'mindalot',
    storageBucket: 'mindalot.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'mindalot',
    storageBucket: 'mindalot.appspot.com',
    iosBundleId: 'com.migs.mindalot',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'mindalot',
    storageBucket: 'mindalot.appspot.com',
  );
}
