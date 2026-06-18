import 'package:flutter/material.dart';
class TermsAgreePage extends StatelessWidget {
  final String packageType;
  const TermsAgreePage({super.key, required this.packageType});
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('약관 동의 ($packageType)')));
}
