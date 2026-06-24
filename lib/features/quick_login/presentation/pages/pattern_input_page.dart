// 패턴 설정/변경 페이지.
//   1) 패턴 그리기 → 2) 한 번 더 그리기(확인). 일치 시 Navigator.pop(context, List<int>).
// 최소 4개 노드 연결을 요구한다.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../widgets/pattern_lock.dart';

class PatternInputPage extends StatefulWidget {
  const PatternInputPage({super.key});

  @override
  State<PatternInputPage> createState() => _PatternInputPageState();
}

class _PatternInputPageState extends State<PatternInputPage> {
  final _lockKey = GlobalKey<PatternLockState>();
  List<int>? _first;
  String? _error;
  bool _err = false;
  int _version = 0;

  void _onCompleted(List<int> points) {
    if (points.length < 4) {
      setState(() {
        _error = '최소 4개의 점을 연결해 주세요.';
        _err = true;
        _version++;
      });
      _resetSoon();
      return;
    }

    if (_first == null) {
      setState(() {
        _first = points;
        _error = null;
        _err = false;
        _version++;
      });
      _resetSoon();
    } else {
      if (_listEq(points, _first!)) {
        Navigator.of(context).pop(points);
      } else {
        setState(() {
          _error = '패턴이 일치하지 않습니다. 처음부터 다시 설정해 주세요.';
          _err = true;
          _first = null;
          _version++;
        });
        _resetSoon();
      }
    }
  }

  void _resetSoon() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _lockKey.currentState?.reset();
    });
  }

  bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '패턴 설정'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _first == null ? '사용할 패턴을 그려주세요' : '패턴을 다시 그려 확인해 주세요',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Text(
                _error ?? '최소 4개의 점을 연결합니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: _err ? Colors.red : AppColors.gray400,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: PatternLock(
                key: ValueKey(_version),
                error: _err,
                onCompleted: _onCompleted,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
