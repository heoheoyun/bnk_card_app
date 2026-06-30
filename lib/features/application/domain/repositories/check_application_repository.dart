import '../entities/check_application.dart';
import '../entities/credit_application.dart' show PaymentSnapshot;

abstract class CheckApplicationRepository {
  /// STEP 1 — 약관 동의, DRAFT 생성 → checkAppId 반환
  Future<int> createApplication(int cardId, List<Map<String, String>> agreedTerms);

  /// STEP 2 — 본인확인 결과 저장 → 'Y' / 'N' 반환
  Future<String> verifyIdentity({
    required int checkAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idPhone,
    required String idIssueDate,
  });

  /// STEP 3 — 기본정보 저장
  Future<void> saveApplicantInfo({
    required int checkAppId,
    required CheckApplicantSnapshot applicantSnapshot,
  });

  /// STEP 4 — 결제정보 저장 & 신청 완료 (REQUESTED)
  Future<void> submitApplication({
    required int checkAppId,
    required PaymentSnapshot paymentSnapshot,
    required int linkedAccountId,
    required String cardPassword,
  });

  /// 신청 단건 조회 (상태 폴링용)
  Future<CheckApplication> getApplication(int checkAppId);

  /// 내 신청 목록 조회 (마이페이지)
  Future<List<CheckApplication>> getMyApplications();

  /// 임시 저장
  Future<CheckApplication?> getDraftApplication(int cardId);

  /// SCREENING_FAILED 상태 심사 재시도
  Future<void> retryScreening(int checkAppId);
}