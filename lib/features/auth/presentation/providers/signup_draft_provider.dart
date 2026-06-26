import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원가입 입력값을 폼 → 이메일 인증 → 약관 동의 화면까지 들고 다니는 draft.
///
/// 서버 SignupRequest 필수 필드(email/password/name/phone/residentFront/
/// genderCode/address)를 모두 보관하고, 약관 페이지에서 agreedTermsIds 와
/// 합쳐 최종 POST /api/auth/signup 을 조립한다.
class SignupDraft {
  final String email;
  final String password;
  final String name;
  final String phone;          // 숫자만 (하이픈 X)
  final String residentFront;  // YYMMDD 6자리
  final String genderCode;     // 1~4, 7~9
  final String address;        // 도로명 + 상세
  final String? birthDate;     // yyyy-MM-dd (선택)
  final bool   marketingAgree; // 선택
  final bool   emailVerified;  // 이메일 인증 완료 여부

  const SignupDraft({
    this.email          = '',
    this.password       = '',
    this.name           = '',
    this.phone          = '',
    this.residentFront  = '',
    this.genderCode     = '',
    this.address        = '',
    this.birthDate,
    this.marketingAgree = false,
    this.emailVerified  = false,
  });

  SignupDraft copyWith({
    String? email,
    String? password,
    String? name,
    String? phone,
    String? residentFront,
    String? genderCode,
    String? address,
    String? birthDate,
    bool?   marketingAgree,
    bool?   emailVerified,
  }) {
    return SignupDraft(
      email:          email ?? this.email,
      password:       password ?? this.password,
      name:           name ?? this.name,
      phone:          phone ?? this.phone,
      residentFront:  residentFront ?? this.residentFront,
      genderCode:     genderCode ?? this.genderCode,
      address:        address ?? this.address,
      birthDate:      birthDate ?? this.birthDate,
      marketingAgree: marketingAgree ?? this.marketingAgree,
      emailVerified:  emailVerified ?? this.emailVerified,
    );
  }
}

class SignupDraftNotifier extends StateNotifier<SignupDraft> {
  SignupDraftNotifier() : super(const SignupDraft());

  void update(SignupDraft Function(SignupDraft) f) => state = f(state);

  void reset() => state = const SignupDraft();
}

final signupDraftProvider =
StateNotifierProvider<SignupDraftNotifier, SignupDraft>(
        (ref) => SignupDraftNotifier());