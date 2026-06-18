// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnk_card_app/app.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────
  // BnkCardApp 기본 렌더링 스모크 테스트
  // - ProviderScope 래핑 확인
  // - MaterialApp.router(GoRouter) 기반이므로 카운터 로직 없음
  // ─────────────────────────────────────────────────────────────────
  testWidgets('BnkCardApp smoke test - 앱이 오류 없이 렌더링된다', (WidgetTester tester) async {
    // ProviderScope로 감싸서 Riverpod 프로바이더 사용 가능하게 설정
    await tester.pumpWidget(
      const ProviderScope(
        child: BnkCardApp(),
      ),
    );

    // GoRouter 초기 라우팅 처리 대기
    await tester.pumpAndSettle();

    // 앱이 정상 빌드되었으면 MaterialApp이 위젯 트리에 존재해야 함
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('BnkCardApp - 초기 화면에 Scaffold가 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BnkCardApp(),
      ),
    );

    // GoRouter redirect + async 처리 대기
    await tester.pumpAndSettle();

    // GoRouter 초기 라우트('/')의 Placeholder Scaffold 렌더링 확인
    expect(find.byType(Scaffold), findsWidgets);
  });
}