import '../../domain/entities/check_application.dart' show CheckApplicantSnapshot;
import '../../domain/entities/credit_application.dart' show PaymentSnapshot;

class CheckApplicationRequestModel {

  // STEP 1 - 약관 동의
  static Map<String, dynamic> step1ToJson({
    required int                     cardId,
    required List<Map<String, String>> agreedTerms,
  }) {
    return {
      'cardId':      cardId,
      'agreedTerms': agreedTerms,
    };
  }

  // STEP 2 - 본인확인
  static Map<String, dynamic> step2ToJson({
    required int    checkAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idPhone,
    required String idIssueDate,
  }) {
    return {
      'checkAppId':   checkAppId,
      'idType':       idType,
      'idName':       idName,
      'idResidentNo': idResidentNo,
      'idAddress':    idAddress,
      'idPhone':      idPhone,
      'idIssueDate':  idIssueDate,
    };
  }

  // STEP 3 - 기본정보
  static Map<String, dynamic> step3ToJson({
    required int                   checkAppId,
    required CheckApplicantSnapshot applicantSnapshot,
  }) {
    return {
      'checkAppId':        checkAppId,
      'applicantSnapshot': {
        'name':               applicantSnapshot.name,
        'nameEn':             applicantSnapshot.nameEn,
        'mobileNo':           applicantSnapshot.mobileNo,
        'address':            applicantSnapshot.address,
        'email':              applicantSnapshot.email,
        'birthDate':          applicantSnapshot.birthDate,
        'jobType':            applicantSnapshot.jobType,
        'transactionPurpose': applicantSnapshot.transactionPurpose,
        'fundSource':         applicantSnapshot.fundSource,
      },
    };
  }

  // STEP 4 - 결제정보 + 신청 완료
  static Map<String, dynamic> step4ToJson({
    required int             checkAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             linkedAccountId,
    required String          cardPassword,
  }) {
    return {
      'checkAppId':      checkAppId,
      'paymentSnapshot': {
        'cardBrand':         paymentSnapshot.cardBrand,
        'cardDesignId':      paymentSnapshot.cardDesignId,
        'paymentDay':        paymentSnapshot.paymentDay,
        'combinedTransitYn': paymentSnapshot.combinedTransitYn,
        'txAlertType':       paymentSnapshot.txAlertType,
        'statementMethod':   paymentSnapshot.statementMethod,
        'deliveryAddress':   paymentSnapshot.deliveryAddress,
        'deliveryZipcode':   paymentSnapshot.deliveryZipcode,
      },
      'linkedAccountId': linkedAccountId,
      'cardPassword':    cardPassword,
    };
  }
}