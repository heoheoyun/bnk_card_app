import 'credit_application.dart' show ApplicationStatus, PaymentSnapshot;

// ── 체크카드 신청인 스냅샷 ─────────────────────────────────────────

/// 신청 시점의 신청인 기본정보 + 거래목적/자금출처
/// Spring CheckApplicantSnapshotDto 기반
///
/// 신용카드와 달리 소득·신용 정보 없이
/// 자금세탁방지(AML) 필수 항목인 [transactionPurpose], [fundSource]가 추가된다.
class CheckApplicantSnapshot {
  final String  name;
  final String? nameEn;
  final String  mobileNo;
  final String  address;
  final String  email;

  /// 직업 구분 (직장인 / 자영업자 / 학생 / 주부 등)
  final String? jobType;

  /// 거래 목적 (급여이체 / 생활비 / 저축 등) — AML 필수
  final String? transactionPurpose;

  /// 자금 출처 (근로소득 / 사업소득 / 연금 등) — AML 필수
  final String? fundSource;

  final String? birthDate; // 추가 — 한도 산정용 (yyyy-MM-dd)

  const CheckApplicantSnapshot({
    required this.name,
    this.nameEn,
    required this.mobileNo,
    required this.address,
    required this.email,
    this.jobType,
    this.transactionPurpose,
    this.fundSource,
    this.birthDate, // 추가
  });

  /// step2(본인확인) 정보를 step3(신청정보)로 옮길 때 사용
  CheckApplicantSnapshot copyWith({
    String? name,
    String? nameEn,
    String? mobileNo,
    String? address,
    String? email,
    String? jobType,
    String? transactionPurpose,
    String? fundSource,
    String? birthDate,
  }) {
    return CheckApplicantSnapshot(
      name:               name ?? this.name,
      nameEn:             nameEn ?? this.nameEn,
      mobileNo:           mobileNo ?? this.mobileNo,
      address:            address ?? this.address,
      email:              email ?? this.email,
      jobType:            jobType ?? this.jobType,
      transactionPurpose: transactionPurpose ?? this.transactionPurpose,
      fundSource:         fundSource ?? this.fundSource,
      birthDate:          birthDate ?? this.birthDate,
    );
  }
}

// ── 체크카드 신청 Entity ───────────────────────────────────────────

/// Spring CheckApplicationResponse 기반 도메인 Entity
///
/// 신용카드와 달리 심사 단계가 단순하다.
/// STEP 4 submit → REQUESTED → 심사서버 결과 콜백 → APPROVED/REJECTED → ISSUED
/// REVIEWING(수동심사) 상태는 체크카드에 존재하지 않는다.
class CheckApplication {
  final int               checkAppId;
  final int               cardId;
  final String?           cardName;
  final String?           cardImageUrl;

  /// Spring application_status 컬럼 → [ApplicationStatus] enum 변환
  /// 체크카드는 DRAFT / REQUESTED / APPROVED / REJECTED / ISSUED만 사용
  final ApplicationStatus applicationStatus;
  final String?           idVerifiedYn;

  final CheckApplicantSnapshot? applicantSnapshot;
  final PaymentSnapshot?        paymentSnapshot;

  /// 연결 계좌 ID (체크카드 필수 — 결제 출금 계좌)
  final int? linkedAccountId;

  /// 거절 사유 (REJECTED 시 세팅)
  final String? rejectionReason;

  /// STEP 4 submit 완료 시점
  final DateTime? appliedAt;

  /// STEP 1 create 시점
  final DateTime? createdAt;

  const CheckApplication({
    required this.checkAppId,
    required this.cardId,
    this.cardName,
    this.cardImageUrl,
    required this.applicationStatus,
    this.idVerifiedYn,
    this.applicantSnapshot,
    this.paymentSnapshot,
    this.linkedAccountId,
    this.rejectionReason,
    this.appliedAt,
    this.createdAt,
  });

  // ── 편의 getter ──────────────────────────────────────────────────

  bool get isDraft     => applicationStatus == ApplicationStatus.draft;
  bool get isIdVerified => idVerifiedYn == 'Y';
  bool get isRequested => applicationStatus == ApplicationStatus.requested;
  bool get isApproved  => applicationStatus == ApplicationStatus.approved;
  bool get isRejected  => applicationStatus == ApplicationStatus.rejected;
  bool get isIssued    => applicationStatus == ApplicationStatus.issued;
}