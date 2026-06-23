// 3x3 패턴 잠금 위젯. 드래그로 노드를 연결하고, 손을 떼면 onCompleted(선택 인덱스 목록) 호출.
// 노드 인덱스: 0~8 (좌상단 0, 우하단 8).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class PatternLock extends StatefulWidget {
  final ValueChanged<List<int>> onCompleted;
  final bool error;
  final double size;

  const PatternLock({
    super.key,
    required this.onCompleted,
    this.error = false,
    this.size = 280,
  });

  @override
  State<PatternLock> createState() => PatternLockState();
}

class PatternLockState extends State<PatternLock> {
  static const int _grid = 3;
  final List<int> _selected = [];
  Offset? _currentPos;

  void reset() => setState(() {
        _selected.clear();
        _currentPos = null;
      });

  List<Offset> _nodeCenters(double side) {
    final gap = side / _grid;
    return List.generate(_grid * _grid, (i) {
      final row = i ~/ _grid;
      final col = i % _grid;
      return Offset(gap * (col + 0.5), gap * (row + 0.5));
    });
  }

  void _handle(Offset local, double side) {
    final centers = _nodeCenters(side);
    final radius = side / _grid / 2 * 0.55;
    for (var i = 0; i < centers.length; i++) {
      if ((local - centers[i]).distance < radius && !_selected.contains(i)) {
        HapticFeedback.selectionClick();
        setState(() => _selected.add(i));
        break;
      }
    }
    setState(() => _currentPos = local);
  }

  void _finish() {
    if (_selected.isEmpty) return;
    final result = List<int>.from(_selected);
    widget.onCompleted(result);
    setState(() => _currentPos = null);
  }

  @override
  Widget build(BuildContext context) {
    final side = widget.size;
    final color = widget.error ? Colors.red : AppColors.primary;
    return SizedBox(
      width: side,
      height: side,
      child: GestureDetector(
        onPanStart: (d) => _handle(d.localPosition, side),
        onPanUpdate: (d) => _handle(d.localPosition, side),
        onPanEnd: (_) => _finish(),
        child: CustomPaint(
          painter: _PatternPainter(
            centers: _nodeCenters(side),
            selected: _selected,
            current: _currentPos,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> centers;
  final List<int> selected;
  final Offset? current;
  final Color color;

  _PatternPainter({
    required this.centers,
    required this.selected,
    required this.current,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()..color = color.withOpacity(0.18);
    final nodeOnPaint = Paint()..color = color;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 노드
    for (var i = 0; i < centers.length; i++) {
      final on = selected.contains(i);
      canvas.drawCircle(centers[i], 22, on ? nodeOnPaint : nodePaint);
      if (on) {
        canvas.drawCircle(
            centers[i], 8, Paint()..color = Colors.white);
      }
    }
    // 연결선
    for (var i = 0; i < selected.length - 1; i++) {
      canvas.drawLine(centers[selected[i]], centers[selected[i + 1]], linePaint);
    }
    // 마지막 노드 → 현재 손가락 위치
    if (selected.isNotEmpty && current != null) {
      canvas.drawLine(centers[selected.last], current!, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) =>
      old.selected.length != selected.length ||
      old.current != current ||
      old.color != color;
}
