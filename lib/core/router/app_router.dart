import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_guards.dart';

class _Placeholder extends StatelessWidget {
  final String name;
  const _Placeholder(this.name);
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(name)),
    body: Center(child: Text(name)),
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: RouteGuards.redirect,
  routes: [
    GoRoute(path: '/',               builder: (_, __) => const _Placeholder('홈 / 카드 목록')),
    GoRoute(path: '/login',          builder: (_, __) => const _Placeholder('로그인')),
    GoRoute(path: '/signup',         builder: (_, __) => const _Placeholder('회원가입')),
    GoRoute(path: '/signup/verify',  builder: (_, __) => const _Placeholder('이메일 인증')),
    GoRoute(path: '/find-id',        builder: (_, __) => const _Placeholder('아이디 찾기')),
    GoRoute(path: '/reset-password', builder: (_, __) => const _Placeholder('비밀번호 재설정')),
    GoRoute(path: '/cards/compare',  builder: (_, __) => const _Placeholder('카드 비교')),
    GoRoute(path: '/cards/:id',      builder: (_, s)  => _Placeholder('카드 상세 ${s.pathParameters['id']}')),
    GoRoute(path: '/search',         builder: (_, __) => const _Placeholder('검색')),
    GoRoute(path: '/spending/input', builder: (_, __) => const _Placeholder('소비패턴 입력')),
    GoRoute(path: '/ai/chat',        builder: (_, __) => const _Placeholder('AI 챗봇')),
    GoRoute(path: '/terms/:type',    builder: (_, s)  => _Placeholder('약관 ${s.pathParameters['type']}')),
    GoRoute(path: '/mypage',         builder: (_, __) => const _Placeholder('마이페이지')),
  ],
);
