import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoAddress {
  final String zonecode;
  final String address;
  final String roadAddress;
  final String jibunAddress;
  final String buildingName;

  const KakaoAddress({
    required this.zonecode,
    required this.address,
    required this.roadAddress,
    required this.jibunAddress,
    required this.buildingName,
  });
}

class KakaoAddressSearchPage extends StatefulWidget {
  const KakaoAddressSearchPage({super.key});

  @override
  State<KakaoAddressSearchPage> createState() => _KakaoAddressSearchPageState();
}

class _KakaoAddressSearchPageState extends State<KakaoAddressSearchPage> {
  late final WebViewController _controller;
  bool _loading = true;

  // ✅ loadHtmlString 대신 base URL을 지정해 외부 스크립트 로드 허용
  static const String _html = '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
        content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    html, body, #wrap { height: 100%; margin: 0; padding: 0; }
    #wrap { width: 100%; }
  </style>
</head>
<body>
  <div id="wrap"></div>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script>
    function startPostcode() {
      new daum.Postcode({
        oncomplete: function (data) {
          var payload = {
            zonecode:     data.zonecode || '',
            roadAddress:  data.roadAddress || '',
            jibunAddress: data.jibunAddress || '',
            address:      data.roadAddress || data.jibunAddress || '',
            buildingName: data.buildingName || ''
          };
          Postcode.postMessage(JSON.stringify(payload));
        },
        onresize: function (size) {
          document.getElementById('wrap').style.height = size.height + 'px';
        },
        width: '100%',
        height: '100%'
      }).embed(document.getElementById('wrap'), { autoClose: true });
    }
    window.onload = startPostcode;
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          // ✅ 에러 로그 — 흰 화면 시 원인 파악용
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.errorCode} / ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Postcode',
        onMessageReceived: (JavaScriptMessage msg) {
          final map = jsonDecode(msg.message) as Map<String, dynamic>;
          final result = KakaoAddress(
            zonecode:     map['zonecode'] as String? ?? '',
            address:      map['address'] as String? ?? '',
            roadAddress:  map['roadAddress'] as String? ?? '',
            jibunAddress: map['jibunAddress'] as String? ?? '',
            buildingName: map['buildingName'] as String? ?? '',
          );
          if (mounted) Navigator.of(context).pop(result);
        },
      )
    // ✅ 핵심 변경: baseUrl을 https://로 지정 → 외부 스크립트 로드 허용
      ..loadHtmlString(_html, baseUrl: 'https://postcode.map.daum.net');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        title: const Text('주소 검색',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}