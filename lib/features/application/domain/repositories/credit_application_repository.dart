import '../entities/credit_application.dart';

abstract class CreditApplicationRepository {
  /// STEP 1 — 약관 동의, DRAFT 생성 → 서버가 발급한 creditAppId 반환
  Future<int> createApplication(int cardId, List<Map<String, String>> agreedTerms);

  /// STEP 2 — 본인확인 결과 저장 → 'Y' / 'N' 반환
  Future<String> verifyIdentity({
    required int creditAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idPhone,
    required String idIssueDate,
  });

  /// STEP 3 — 기본정보 + 직업/소득 저장
  Future<void> saveApplicantInfo({
    required int creditAppId,
    required CreditApplicantSnapshot applicantSnapshot,
    required String annualIncomeBand,
    required String creditScoreBand,
    required int linkedAccountId,
  });

  /// STEP 4+5 — 결제정보 + 서류(신규고객) 저장 & 신청 완료 (REQUESTED)
  Future<void> submitApplication({
    required int creditAppId,
    required PaymentSnapshot paymentSnapshot,
    required int requestedLimit,
    required String cardPassword,
    String? incomeDocKey,   // 신규고객만
    String? assetDocKey,    // 신규고객 선택
    String? jobDocKey,      // 신규고객만
  });

  /// 기존고객 여부 확인 (STEP 5 서류 화면 노출 여부 판단)
  Future<bool> checkExistingCustomer(int creditAppId);

  /// 신청 단건 조회 (상태 폴링용)
  Future<CreditApplication> getApplication(int creditAppId);

  /// 내 신청 목록 조회 (마이페이지)
  Future<List<CreditApplication>> getMyApplications();

  /// 임시저장
  Future<CreditApplication?> getDraftApplication(int cardId);

  /// SCREENING_FAILED 상태 심사 재시도
  Future<void> retryScreening(int creditAppId);
}