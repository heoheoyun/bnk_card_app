// 간편비밀번호(PIN) 설정/변경 페이지.
//   1) 새 PIN 입력 → 2) 한 번 더 입력(확인). 일치하면 Navigator.pop(context, pin).
// 설정 화면에서 `Navigator.push<String>(...)` 로 띄우고 결과를 받아 저장한다.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../widgets/pin_pad.dart';

class PinInputPage extends StatefulWidget {
  final int length;
  const PinInputPage({super.key, this.length = 6});

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  final _padKey = GlobalKey<PinPadState>();
  String? _first; // 1단계 입력값
  String? _error;
  int _padVersion = 0; // 입력 초기화용

  void _onCompleted(String value) {
    if (_first == null) {
      // 1단계 완료 → 확인 단계로
      setState(() {
        _first = value;
        _error = null;
        _padVersion++;
      });
      _padKey.currentState?.reset();
    } else {
      if (value == _first) {
        Navigator.of(context).pop(value);
      } else {
        setState(() {
          _error = 'PIN이 일치하지 않습니다. 다시 설정해 주세요.';
          _first = null;
          _padVersion++;
        });
        _padKey.currentState?.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _first == null ? '새 PIN 입력' : 'PIN 다시 입력';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '간편비밀번호 설정'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              _first == null
                  ? '${widget.length}자리 숫자를 입력해 주세요.'
                  : '확인을 위해 한 번 더 입력해 주세요.',
              style: TextStyle(fontSize: 13, color: AppColors.gray400),
            ),
            const Spacer(),
            PinPad(
              key: ValueKey(_padVersion),
              length: widget.length,
              errorText: _error,
              onCompleted: _onCompleted,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
