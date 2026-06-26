import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/local_storage.dart';
import 'core/network/dio_client.dart';
import 'core/push/push_service.dart';
import 'app.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await DioClient.init();

  await Firebase.initializeApp();  // ← 주석 해제
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);  // ← 주석 해제

  runApp(const ProviderScope(child: BnkCardApp()));
}