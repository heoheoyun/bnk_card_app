import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_paths.dart';
import '../../domain/entities/check_application.dart';
import '../../domain/entities/credit_application.dart' show PaymentSnapshot;
import '../models/check_application_model.dart';
import '../models/check_application_request_model.dart';

class CheckApplicationRemoteDatasource {
  final _dio = DioClient.instance;

  // STEP 1 - 약관 동의 → checkAppId 반환
  Future<int> createApplication({
    required int                       cardId,
    required List<Map<String, String>> agreedTerms,
  }) async {
    final res = await _dio.post(
      ApiPaths.createCheckApplication,
      data: CheckApplicationRequestModel.step1ToJson(
        cardId:      cardId,
        agreedTerms: agreedTerms,
      ),
    );
    return (res.data['data'] as num).toInt();
  }

  // STEP 2 - 본인확인 → 'Y' / 'N' 반환
  Future<String> verifyIdentity({
    required int    checkAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) async {
    final res = await _dio.post(
      ApiPaths.verifyCheckIdentity,
      data: CheckApplicationRequestModel.step2ToJson(
        checkAppId:   checkAppId,
        idType:       idType,
        idName:       idName,
        idResidentNo: idResidentNo,
        idAddress:    idAddress,
        idIssueDate:  idIssueDate,
      ),
    );
    return res.data['data'] as String;
  }

  // STEP 3 - 기본정보 저장
  Future<void> saveApplicantInfo({
    required int                    checkAppId,
    required CheckApplicantSnapshot applicantSnapshot,
  }) async {
    await _dio.post(
      ApiPaths.saveCheckApplicantInfo,
      data: CheckApplicationRequestModel.step3ToJson(
        checkAppId:        checkAppId,
        applicantSnapshot: applicantSnapshot,
      ),
    );
  }

  // STEP 4 - 결제정보 + 신청 완료
  Future<void> submitApplication({
    required int             checkAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             linkedAccountId,
    required String          cardPassword,
  }) async {
    await _dio.post(
      ApiPaths.submitCheckApplication,
      data: CheckApplicationRequestModel.step4ToJson(
        checkAppId:      checkAppId,
        paymentSnapshot: paymentSnapshot,
        linkedAccountId: linkedAccountId,
        cardPassword:    cardPassword,
      ),
    );
  }

  // 신청 단건 조회
  Future<CheckApplication> getApplication(int checkAppId) async {
    final res = await _dio.get(
      '${ApiPaths.checkApplications}/$checkAppId',
    );
    return CheckApplicationModel.fromJson(res.data['data']);
  }

  // 내 신청 목록 조회
  Future<List<CheckApplication>> getMyApplications() async {
    final res = await _dio.get(ApiPaths.checkApplications);
    return (res.data['data'] as List)
        .map((e) => CheckApplicationModel.fromJson(e))
        .toList();
  }
}