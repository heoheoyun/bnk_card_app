// BNK 카드 앱 아이콘 PNG 생성기.
//   실행: dart run tool/gen_icon.dart
//   출력: assets/icons/app_icon.png      (전체 아이콘 — teal 배경 + 카드, 레거시/iOS용)
//         assets/icons/app_icon_fg.png   (적응형 전경 — 투명 배경 + 카드)
// 이후: dart run flutter_launcher_icons  으로 런처 아이콘 일괄 생성.

import 'dart:io';
import 'package:image/image.dart' as img;

const int _size = 1024;

void main() {
  _draw(withBackground: true, out: 'assets/icons/app_icon.png');
  _draw(withBackground: false, out: 'assets/icons/app_icon_fg.png');
}

void _draw({required bool withBackground, required String out}) {
  final image = img.Image(width: _size, height: _size, numChannels: 4);
  // 투명 초기화
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  final teal = img.ColorRgba8(0x00, 0x67, 0x7F, 255); // teal600
  final white = img.ColorRgba8(0xFF, 0xFF, 0xFF, 255);
  final gold = img.ColorRgba8(0xE2, 0xB8, 0x57, 255);
  final lite = img.ColorRgba8(0x9F, 0xC9, 0xD3, 255);

  // 배경 (전체 아이콘에만)
  if (withBackground) {
    img.fillRect(image,
        x1: 0, y1: 0, x2: _size - 1, y2: _size - 1, color: teal, radius: 220);
  }

  // 카드 본체 (흰색, 중앙 안전영역 안)
  img.fillRect(image, x1: 232, y1: 332, x2: 792, y2: 692, color: white, radius: 48);
  // IC 칩 (골드)
  img.fillRect(image, x1: 300, y1: 420, x2: 430, y2: 516, color: gold, radius: 16);
  // 카드번호 스트라이프
  img.fillRect(image, x1: 300, y1: 566, x2: 720, y2: 600, color: teal, radius: 12);
  img.fillRect(image, x1: 300, y1: 616, x2: 600, y2: 650, color: lite, radius: 12);

  File(out).parent.createSync(recursive: true);
  File(out).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $out');
}
