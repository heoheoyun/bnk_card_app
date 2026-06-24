import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/local_storage.dart';
import 'core/network/dio_client.dart';
import 'core/push/push_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await DioClient.init(); // 쿠키 저장소 + Dio 초기화 (반드시 runApp 전)

  // Firebase 초기화 (Android: google-services.json / iOS: GoogleService-Info.plist 자동 인식)
  // flutterfire configure 로 firebase_options.dart 를 생성했다면:
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 임시 비활성화 ---------------------------------------------------------
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: BnkCardApp()));
}