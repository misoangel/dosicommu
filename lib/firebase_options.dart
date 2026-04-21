// 이 파일은 FlutterFire CLI로 자동 생성됩니다
// flutterfire configure 명령어로 생성하세요
// 또는 google-services.json을 android/app/ 에 넣으면 자동으로 설정됩니다

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // 이 값들은 google-services.json에서 자동으로 읽어옵니다
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'dosicommu',
    storageBucket: 'dosicommu.appspot.com',
  );
}
