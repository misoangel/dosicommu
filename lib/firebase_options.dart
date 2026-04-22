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
  apiKey: 'AIzaSyDHD4Hv3dbrd3x0bZi7H2v1mzD4Pv8ywQU',
  appId: '1:1023952867123:android:753694796e2c17c17f7846',
  messagingSenderId: '1023952867123',
  projectId: 'dosicommu',
  storageBucket: 'dosicommu.firebasestorage.app',
);
}
