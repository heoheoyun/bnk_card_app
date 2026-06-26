/// 서버 com.bnk.domain.auth.dto.request.SignupRequest 와 1:1 매핑.
///
/// 필수: email, password, name, phone, agreedTermsIds, residentFront,
///       genderCode, address
/// 선택: birthDate, marketingAgree, job, incomeLevelCode, creditScore
///
/// 주의:
///  - phone 은 서버 @Pattern ^01[0-9]{8,9}$ 라 하이픈 불가 → toJson 에서 숫자만 정제
///  - 선택 필드는 값이 있을 때만 직렬화 (불필요한 @Pattern 검증 회피)
///  - creditScore 는 보통 서버 산정 → 클라이언트에서 임의 전송 비권장(여기선 미포함)
class SignupRequest {
  // 필수
  final String    email;
  final String    password;
  final String    name;
  final String    phone;
  final List<int> agreedTermsIds;
  final String    residentFront;
  final String    genderCode;
  final String    address;

  // 선택
  final String? birthDate;
  final bool?   marketingAgree;
  final String? job;
  final String? incomeLevelCode;
  final int?    creditScore;

  const SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.agreedTermsIds,
    required this.residentFront,
    required this.genderCode,
    required this.address,
    this.birthDate,
    this.marketingAgree,
    this.job,
    this.incomeLevelCode,
    this.creditScore,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'email':          email.trim(),
      'password':       password,
      'name':           name.trim(),
      'phone':          phone.replaceAll(RegExp(r'\D'), ''), // 숫자만
      'agreedTermsIds': agreedTermsIds,
      'residentFront':  residentFront,
      'genderCode':     genderCode,
      'address':        address.trim(),
    };
    if (birthDate != null && birthDate!.isNotEmpty) {
      m['birthDate'] = birthDate;
    }
    if (marketingAgree != null) {
      m['marketingAgree'] = marketingAgree;
    }
    if (job != null && job!.isNotEmpty) {
      m['job'] = job;
    }
    if (incomeLevelCode != null && incomeLevelCode!.isNotEmpty) {
      m['incomeLevelCode'] = incomeLevelCode;
    }
    if (creditScore != null) {
      m['creditScore'] = creditScore;
    }
    return m;
  }
}
