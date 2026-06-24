// 숫자 키패드 + 입력 점 표시. 입력이 [length]자리에 도달하면 onCompleted 호출.
// 검증/저장 로직은 포함하지 않는다(상위 페이지 책임).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class PinPad extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  /// 외부에서 입력을 비우고 흔들기 애니메이션을 트리거하기 위한 키.
  /// (예: 검증 실패 시 부모가 setState 로 새 ValueKey 전달)
  const PinPad({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.errorText,
  });

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> {
  String _input = '';

  void reset() => setState(() => _input = '');

  void _onDigit(String d) {
    if (_input.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _input += d);
    if (_input.length == widget.length) {
      widget.onCompleted(_input);
    }
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 입력 점 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (i) {
            final filled = i < _input.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: widget.errorText != null
                      ? Colors.red
                      : AppColors.primary,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 20,
          child: widget.errorText != null
              ? Text(widget.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13))
              : null,
        ),
        const SizedBox(height: 24),
        // ── 키패드 ──
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map(_buildKey).toList(),
          ),
      ],
    );
  }

  Widget _buildKey(String label) {
    if (label.isEmpty) {
      return const SizedBox(width: 84, height: 84);
    }
    final isBackspace = label == '⌫';
    return SizedBox(
      width: 84,
      height: 84,
      child: InkWell(
        borderRadius: BorderRadius.circular(42),
        onTap: isBackspace ? _onBackspace : () => _onDigit(label),
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 26)
              : Text(label,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
