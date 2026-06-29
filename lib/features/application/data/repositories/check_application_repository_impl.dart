import '../../domain/entities/check_application.dart';
import '../../domain/entities/credit_application.dart' show PaymentSnapshot;
import '../../domain/repositories/check_application_repository.dart';
import '../datasource/check_application_remote_datasource.dart';

class CheckApplicationRepositoryImpl implements CheckApplicationRepository {
  final CheckApplicationRemoteDatasource _ds;
  CheckApplicationRepositoryImpl(this._ds);

  @override
  Future<int> createApplication(
      int cardId,
      List<Map<String, String>> agreedTerms,
      ) {
    return _ds.createApplication(
      cardId:      cardId,
      agreedTerms: agreedTerms,
    );
  }

  @override
  Future<String> verifyIdentity({
    required int    checkAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) {
    return _ds.verifyIdentity(
      checkAppId:   checkAppId,
      idType:       idType,
      idName:       idName,
      idResidentNo: idResidentNo,
      idAddress:    idAddress,
      idIssueDate:  idIssueDate,
    );
  }

  @override
  Future<void> saveApplicantInfo({
    required int                    checkAppId,
    required CheckApplicantSnapshot applicantSnapshot,
  }) {
    return _ds.saveApplicantInfo(
      checkAppId:        checkAppId,
      applicantSnapshot: applicantSnapshot,
    );
  }

  @override
  Future<void> submitApplication({
    required int             checkAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             linkedAccountId,
    required String          cardPassword,
  }) {
    return _ds.submitApplication(
      checkAppId:      checkAppId,
      paymentSnapshot: paymentSnapshot,
      linkedAccountId: linkedAccountId,
      cardPassword:    cardPassword,
    );
  }

  @override
  Future<CheckApplication> getApplication(int checkAppId) {
    return _ds.getApplication(checkAppId);
  }

  @override
  Future<List<CheckApplication>> getMyApplications() {
    return _ds.getMyApplications();
  }

  @override
  Future<CheckApplication?> getDraftApplication(int cardId) {
    return _ds.getDraftApplication(cardId);
  }

  @override
  Future<void> retryScreening(int checkAppId) {
    return _ds.retryScreening(checkAppId);
  }
}