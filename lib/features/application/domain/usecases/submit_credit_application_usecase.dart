import '../entities/credit_application.dart';
import '../repositories/credit_application_repository.dart';

class SubmitCreditApplicationUsecase {
  final CreditApplicationRepository _repo;
  SubmitCreditApplicationUsecase(this._repo);

  Future<void> call({
    required int             creditAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             requestedLimit,
    required String          cardPassword,
    String? incomeDocKey,
    String? assetDocKey,
    String? jobDocKey,
  }) async {
    // 신규고객이면 필수 서류 체크
    if (incomeDocKey == null && jobDocKey == null) {
      // 기존고객 케이스 — 서류 없이 그냥 제출
    } else if (incomeDocKey == null || jobDocKey == null) {
      throw Exception('소득확인서류와 직업확인서류는 필수입니다.');
    }

    await _repo.submitApplication(
      creditAppId:     creditAppId,
      paymentSnapshot: paymentSnapshot,
      requestedLimit:  requestedLimit,
      cardPassword:    cardPassword,
      incomeDocKey:    incomeDocKey,
      assetDocKey:     assetDocKey,
      jobDocKey:       jobDocKey,
    );
  }
}