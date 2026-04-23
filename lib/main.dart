import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DosicommuApp());

  // 👉 앱 실행 후에 알림 초기화 (중요)
  NotificationService.initialize();
}

class DosicommuApp extends StatelessWidget {
  const DosicommuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '도시위원회',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
