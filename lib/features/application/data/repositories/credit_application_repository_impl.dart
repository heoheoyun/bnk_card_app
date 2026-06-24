import '../../domain/entities/credit_application.dart';
import '../../domain/repositories/credit_application_repository.dart';
import '../datasource/credit_application_remote_datasource.dart';

class CreditApplicationRepositoryImpl implements CreditApplicationRepository {
  final CreditApplicationRemoteDatasource _ds;
  CreditApplicationRepositoryImpl(this._ds);

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
    required int    creditAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) {
    return _ds.verifyIdentity(
      creditAppId:  creditAppId,
      idType:       idType,
      idName:       idName,
      idResidentNo: idResidentNo,
      idAddress:    idAddress,
      idIssueDate:  idIssueDate,
    );
  }

  @override
  Future<void> saveApplicantInfo({
    required int                     creditAppId,
    required CreditApplicantSnapshot applicantSnapshot,
    required String                  annualIncomeBand,
    required String                  creditScoreBand,
    required int                     linkedAccountId,
  }) {
    return _ds.saveApplicantInfo(
      creditAppId:       creditAppId,
      applicantSnapshot: applicantSnapshot,
      annualIncomeBand:  annualIncomeBand,
      creditScoreBand:   creditScoreBand,
      linkedAccountId:   linkedAccountId,
    );
  }

  @override
  Future<void> submitApplication({
    required int             creditAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             requestedLimit,
    required String          cardPassword,
    String? incomeDocKey,
    String? assetDocKey,
    String? jobDocKey,
  }) {
    return _ds.submitApplication(
      creditAppId:     creditAppId,
      paymentSnapshot: paymentSnapshot,
      requestedLimit:  requestedLimit,
      cardPassword:    cardPassword,
      incomeDocKey:    incomeDocKey,
      assetDocKey:     assetDocKey,
      jobDocKey:       jobDocKey,
    );
  }

  @override
  Future<bool> checkExistingCustomer(int creditAppId) {
    return _ds.checkExistingCustomer(creditAppId);
  }

  @override
  Future<CreditApplication> getApplication(int creditAppId) {
    return _ds.getApplication(creditAppId);
  }

  @override
  Future<List<CreditApplication>> getMyApplications() {
    return _ds.getMyApplications();
  }
}