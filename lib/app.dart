import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

class BnkApp extends StatelessWidget {
  const BnkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BNK 부산은행',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}