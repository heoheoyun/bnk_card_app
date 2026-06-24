/// 발급된 실제 카드 도메인 Entity
///
/// Spring UserCard 모델 기반
/// 신용카드·체크카드 발급 후 USER_CARDS 테이블에 공통으로 저장되는 구조

// ── 카드 상태 ──────────────────────────────────────────────────────

/// Spring card_status 컬럼 값과 1:1 대응
enum CardStatus {
  active,    // ACTIVE  : 정상 사용 중
  lost,      // LOST    : 분실 신고
  stopped,   // STOPPED : 일시 정지
  expired,   // EXPIRED : 유효기간 만료
  reissued;  // REISSUED: 재발급(구카드 비활성)

  static CardStatus fromString(String value) {
    return CardStatus.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => CardStatus.active,
    );
  }

  String get label => switch (this) {
    CardStatus.active   => '정상',
    CardStatus.lost     => '분실',
    CardStatus.stopped  => '정지',
    CardStatus.expired  => '만료',
    CardStatus.reissued => '재발급',
  };

  bool get isUsable => this == CardStatus.active;
}

// ── 발급 카드 Entity ───────────────────────────────────────────────

/// 사용자에게 발급된 실물 카드 정보
///
/// 카드번호는 서버에서 AES 암호화 저장되며,
/// Flutter 앱에는 마스킹 번호([maskedCardNumber])만 내려온다.
/// [creditAppId] 또는 [checkAppId] 중 하나만 세팅된다.
class UserCard {
  // ── 식별자 ────────────────────────────────────────────────────────
  final int  userCardId;
  final int  userId;
  final int  versionId;

  /// 신용카드 발급 시 세팅, 체크카드 시 null
  final int? creditAppId;

  /// 체크카드 발급 시 세팅, 신용카드 시 null
  final int? checkAppId;

  // ── 카드번호 ─────────────────────────────────────────────────────

  /// 화면 표시용 마스킹 번호 (예: 1234-56**-****-7890)
  /// 서버가 MaskingUtil.maskCardNumber()로 가공해서 내려준다.
  final String maskedCardNumber;

  // ── 유효기간 / 상태 ───────────────────────────────────────────────
  final DateTime  issueDate;
  final DateTime  expireDate;
  final CardStatus cardStatus;

  /// 사용 가능 여부 Y/N (정지·분실 시 'N')
  final String usableYn;

  // ── 연결 계좌 ────────────────────────────────────────────────────

  /// 체크카드: 필수(출금 계좌) / 신용카드: 연회비 자동이체 계좌 (선택)
  final int? linkedAccountId;

  // ── 한도 ──────────────────────────────────────────────────────────

  /// 일일 한도 — 발급 시 기본 100만원
  final int dailyLimitAmount;

  /// 월 한도 — 신용카드: 승인 한도, 체크카드: null
  final int? monthlyLimitAmount;

  // ── 결제 설정 (payment_snapshot에서 플랫화) ───────────────────────

  /// VISA / MASTER / AMEX / LOCAL
  final String? cardBrand;

  /// FK: CARD_IMAGES.image_id — 사용자가 선택한 디자인
  final int? cardDesignId;

  /// 월 결제일 (1~31), 체크카드는 null
  final int? paymentDay;

  /// 후불교통 결합 여부 Y/N
  final String? combinedTransitYn;

  /// 거래알림 방식 SMS / PUSH / NONE
  final String? txAlertType;

  /// 청구서 방식 EMAIL / APP / PAPER
  final String? statementMethod;

  // ── 해외 / 비접촉 설정 ───────────────────────────────────────────

  /// 해외 사용 가능 여부 (발급 후 변경 가능, 기본 Y)
  final String? overseasEnabledYn;

  /// 비접촉 결제 가능 여부 (발급 후 변경 가능, 기본 Y)
  final String? contactlessEnabledYn;

  // ── 카드 별칭 ────────────────────────────────────────────────────

  /// 마이페이지에서 사용자가 직접 설정하는 카드 이름
  final String? cardNickname;

  // ── 감사 ──────────────────────────────────────────────────────────
  final DateTime? issuedAt;
  final DateTime? updatedAt;

  const UserCard({
    required this.userCardId,
    required this.userId,
    required this.versionId,
    this.creditAppId,
    this.checkAppId,
    required this.maskedCardNumber,
    required this.issueDate,
    required this.expireDate,
    required this.cardStatus,
    required this.usableYn,
    this.linkedAccountId,
    required this.dailyLimitAmount,
    this.monthlyLimitAmount,
    this.cardBrand,
    this.cardDesignId,
    this.paymentDay,
    this.combinedTransitYn,
    this.txAlertType,
    this.statementMethod,
    this.overseasEnabledYn,
    this.contactlessEnabledYn,
    this.cardNickname,
    this.issuedAt,
    this.updatedAt,
  });

  // ── 편의 getter ──────────────────────────────────────────────────

  /// 신용카드 여부
  bool get isCreditCard => creditAppId != null;

  /// 체크카드 여부
  bool get isCheckCard  => checkAppId != null;

  /// 실제 사용 가능 여부 (status + usableYn 동시 체크)
  bool get canUse => cardStatus.isUsable && usableYn == 'Y';

  /// 만료 여부 (유효기간 기준)
  bool get isExpired => expireDate.isBefore(DateTime.now());

  /// 화면에 표시할 카드명 (별칭 있으면 우선)
  String displayName(String cardName) => cardNickname ?? cardName;
}