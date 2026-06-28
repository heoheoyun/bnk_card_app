import '../entities/credit_application.dart' show PaymentSnapshot;
import '../repositories/check_application_repository.dart';

class SubmitCheckApplicationUsecase {
  final CheckApplicationRepository _repo;
  SubmitCheckApplicationUsecase(this._repo);

  Future<void> call({
    required int             checkAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             linkedAccountId,
    required String          cardPassword,
  }) {
    return _repo.submitApplication(
      checkAppId:      checkAppId,
      paymentSnapshot: paymentSnapshot,
      linkedAccountId: linkedAccountId,
      cardPassword:    cardPassword,
    );
  }
}