/// 신용카드 신청 도메인 Entity
///
/// Spring CreditCardApplicationResponse + CreditApplicantSnapshotDto + PaymentSnapshotDto 기반
/// PaymentSnapshot은 체크카드 Entity에서도 import해서 공용으로 사용한다.

// ── 신청 상태 ──────────────────────────────────────────────────────

/// Spring application_status 컬럼 값과 1:1 대응
enum ApplicationStatus {
  draft,      // DRAFT    : 약관 동의 직후, 신청 진행 중
  requested,  // REQUESTED: 신청 완료 → 심사 대기
  reviewing,  // REVIEWING: 한도 초과 → 수동 심사 중 (신용카드 전용)
  approved,   // APPROVED : 심사 통과
  rejected,   // REJECTED : 심사 거절
  issued;     // ISSUED   : 카드 발급 완료

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ApplicationStatus.draft,
    );
  }

  String get label => switch (this) {
    ApplicationStatus.draft      => '신청 중',
    ApplicationStatus.requested  => '심사 대기',
    ApplicationStatus.reviewing  => '심사 중',
    ApplicationStatus.approved   => '승인',
    ApplicationStatus.rejected   => '거절',
    ApplicationStatus.issued     => '발급 완료',
  };
}

// ── 결제 스냅샷 (신용·체크 공용) ──────────────────────────────────

/// 신청 시점에 저장되는 결제 설정 정보
/// Spring PaymentSnapshotDto → payment_snapshot JSON 컬럼 역직렬화 결과
class PaymentSnapshot {
  /// VISA / MASTER / AMEX / LOCAL
  final String? cardBrand;

  /// FK: CARD_IMAGES.image_id — 사용자가 선택한 디자인
  final String? cardDesignId;

  /// 월 결제일 (1~30)
  final int? paymentDay;

  /// 후불교통 결합 여부 Y/N
  final String? combinedTransitYn;

  /// 거래알림 방식 SMS / PUSH / NONE
  final String? txAlertType;

  /// 청구서 방식 EMAIL / APP / PAPER
  final String? statementMethod;

  const PaymentSnapshot({
    this.cardBrand,
    this.cardDesignId,
    this.paymentDay,
    this.combinedTransitYn,
    this.txAlertType,
    this.statementMethod,
  });
}

// ── 신용카드 신청인 스냅샷 ─────────────────────────────────────────

/// 신청 시점의 신청인 기본정보 + 직업/소득 정보
/// Spring CreditApplicantSnapshotDto 기반
class CreditApplicantSnapshot {
  final String  name;
  final String? nameEn;
  final String  mobileNo;
  final String  address;
  final String  email;

  /// 직업 구분 (직장인 / 자영업자 / 전문직 등)
  final String? incomeType;

  /// 건강보험 유형 (직장가입자 / 지역가입자)
  final String? healthInsuranceType;

  /// 부동산 보유 여부 Y/N
  final String? hasRealEstate;

  /// 자차 보유 여부 Y/N
  final String? hasOwnVehicle;

  const CreditApplicantSnapshot({
    required this.name,
    this.nameEn,
    required this.mobileNo,
    required this.address,
    required this.email,
    this.incomeType,
    this.healthInsuranceType,
    this.hasRealEstate,
    this.hasOwnVehicle,
  });
}

// ── 신용카드 신청 Entity ───────────────────────────────────────────

/// Spring CreditApplicationResponse 기반 도메인 Entity
///
/// [applicantSnapshot], [paymentSnapshot]은 서버에서 JSON 역직렬화 후
/// RepositoryImpl에서 변환해 주입한다.
/// Flutter 앱은 심사 중(REVIEWING)까지만 상태를 폴링하며,
/// STEP 6~8(심사 콜백)은 서버 내부 처리이므로 조회 전용으로만 노출된다.
class CreditApplication {
  final int               creditAppId;
  final int               cardId;
  final String?           cardName;
  final String?           cardImageUrl;

  /// Spring application_status 컬럼 → [ApplicationStatus] enum 변환
  final ApplicationStatus applicationStatus;
  final String?           idVerifiedYn;

  final CreditApplicantSnapshot? applicantSnapshot;
  final PaymentSnapshot?         paymentSnapshot;
  final String? annualIncomeBand;
  final String? creditScoreBand;
  final int?    linkedAccountId;

  /// 승인 한도 (APPROVED 이후 세팅)
  final int? approvedLimit;

  /// 신청 시 사용자가 요청한 한도
  final int? requestedLimit;

  /// 거절 사유 (REJECTED 시 세팅)
  final String? rejectionReason;

  /// STEP 4 submit 완료 시점 (REQUESTED 전환 시각)
  final DateTime? appliedAt;

  /// STEP 1 create 시점 (DRAFT 생성 시각)
  final DateTime? createdAt;

  const CreditApplication({
    required this.creditAppId,
    required this.cardId,
    this.cardName,
    this.cardImageUrl,
    required this.applicationStatus,
    this.idVerifiedYn,
    this.applicantSnapshot,
    this.paymentSnapshot,
    this.annualIncomeBand,
    this.creditScoreBand,
    this.linkedAccountId,
    this.approvedLimit,
    this.requestedLimit,
    this.rejectionReason,
    this.appliedAt,
    this.createdAt,
  });

  // ── 편의 getter ──────────────────────────────────────────────────

  bool get isDraft      => applicationStatus == ApplicationStatus.draft;
  bool get isIdVerified => idVerifiedYn == 'Y';
  bool get isRequested  => applicationStatus == ApplicationStatus.requested;
  bool get isReviewing  => applicationStatus == ApplicationStatus.reviewing;
  bool get isApproved   => applicationStatus == ApplicationStatus.approved;
  bool get isRejected   => applicationStatus == ApplicationStatus.rejected;
  bool get isIssued     => applicationStatus == ApplicationStatus.issued;
}