import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 알림 권한 요청
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM 토큰 저장
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('fcm')
          .set({'token': token}, SetOptions(merge: true));
    }

    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen((message) {
      print('포그라운드 메시지: ${message.notification?.title}');
    });
  }

  // D-day 알림 스케줄 등록
  static Future<void> scheduleTaskNotifications(String sessionId) async {
    // Firebase Functions 또는 GitHub Actions에서 처리
    // 여기서는 Firestore에 알림 예약 정보만 저장
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({
      'sessionId': sessionId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
