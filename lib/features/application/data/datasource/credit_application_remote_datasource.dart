import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_paths.dart';
import '../../domain/entities/credit_application.dart';
import '../../domain/entities/check_application.dart';
import '../models/credit_application_model.dart';
import '../models/credit_application_request_model.dart';

class CreditApplicationRemoteDatasource {
  final _dio = DioClient.instance;

  // STEP 1 - 약관 동의 → creditAppId 반환
  Future<int> createApplication({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) async {
    final res = await _dio.post(
      ApiPaths.createCreditApplication,
      data: CreditApplicationRequestModel.step1ToJson(
        cardId:      cardId,
        agreedTerms: agreedTerms,
      ),
    );
    return (res.data['data'] as num).toInt();
  }

  // STEP 2 - 본인확인 → 'Y' / 'N' 반환
  Future<String> verifyIdentity({
    required int    creditAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) async {
    final res = await _dio.post(
      ApiPaths.verifyCreditIdentity,
      data: CreditApplicationRequestModel.step2ToJson(
        creditAppId:  creditAppId,
        idType:       idType,
        idName:       idName,
        idResidentNo: idResidentNo,
        idAddress:    idAddress,
        idIssueDate:  idIssueDate,
      ),
    );
    return res.data['data'] as String;
  }

  // STEP 3 - 기본정보 + 직업/소득 저장
  Future<void> saveApplicantInfo({
    required int                     creditAppId,
    required CreditApplicantSnapshot applicantSnapshot,
    required String                  annualIncomeBand,
    required String                  creditScoreBand,
    required int                     linkedAccountId,
  }) async {
    await _dio.post(
      ApiPaths.saveCreditApplicantInfo,
      data: CreditApplicationRequestModel.step3ToJson(
        creditAppId:       creditAppId,
        applicantSnapshot: applicantSnapshot,
        annualIncomeBand:  annualIncomeBand,
        creditScoreBand:   creditScoreBand,
        linkedAccountId:   linkedAccountId,
      ),
    );
  }

  // STEP 4+5 - 결제정보 + 서류 + 신청 완료
  Future<void> submitApplication({
    required int             creditAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             requestedLimit,
    required String          cardPassword,
    String? incomeDocKey,
    String? assetDocKey,
    String? jobDocKey,
  }) async {
    await _dio.post(
      ApiPaths.submitCreditApplication,
      data: CreditApplicationRequestModel.step4ToJson(
        creditAppId:      creditAppId,
        paymentSnapshot:  paymentSnapshot,
        requestedLimit:   requestedLimit,
        cardPassword:     cardPassword,
        incomeDocKey:     incomeDocKey,
        assetDocKey:      assetDocKey,
        jobDocKey:        jobDocKey,
      ),
    );
  }

  // 기존고객 여부 확인
  Future<bool> checkExistingCustomer(int creditAppId) async {
    final res = await _dio.get(
      ApiPaths.checkCreditExistingCustomer,
      queryParameters: {'creditAppId': creditAppId},
    );
    return res.data['data'] as bool;
  }

  // 신청 단건 조회
  Future<CreditApplication> getApplication(int creditAppId) async {
    final res = await _dio.get(
      '${ApiPaths.creditApplications}/$creditAppId',
    );
    return CreditApplicationModel.fromJson(res.data['data']);
  }

  // 내 신청 목록 조회
  Future<List<CreditApplication>> getMyApplications() async {
    final res = await _dio.get(ApiPaths.creditApplications);
    return (res.data['data'] as List)
        .map((e) => CreditApplicationModel.fromJson(e))
        .toList();
  }

  // DRAFT 조회
  Future<CreditApplication?> getDraftApplication(int cardId) async {
    final res = await _dio.get(
      ApiPaths.creditApplicationDraft,
      queryParameters: {'cardId': cardId},
    );
    if (res.data['data'] == null) return null;
    return CreditApplicationModel.fromJson(res.data['data']);
  }
}