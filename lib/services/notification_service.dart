import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // 권한 요청 (기다리지 않음)
      _messaging.requestPermission();

      // 토큰 가져오기 (백그라운드 실행)
      _messaging.getToken().then((token) {
        if (token != null) {
          FirebaseFirestore.instance
              .collection('settings')
              .doc('fcm')
              .set({'token': token}, SetOptions(merge: true));
        }
      });

      // 메시지 수신
      FirebaseMessaging.onMessage.listen((message) {
        print('메시지 도착: ${message.notification?.title}');
      });
    } catch (e) {
      print('알림 초기화 에러: $e');
    }
  }
}
