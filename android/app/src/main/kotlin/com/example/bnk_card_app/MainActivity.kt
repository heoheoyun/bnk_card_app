package com.example.bnk_card_app

import io.flutter.embedding.android.FlutterFragmentActivity

// #4 생체인증 수정의 핵심.
// local_auth(androidx.biometric.BiometricPrompt)는 FragmentActivity 위에서만 동작한다.
// 기존 FlutterActivity 에서는 authenticate() 호출 시 'no_fragment_activity' 예외가 발생해
// 생체인증 등록이 항상 실패했다. FlutterFragmentActivity 로 교체하면 정상 동작한다.
class MainActivity : FlutterFragmentActivity()