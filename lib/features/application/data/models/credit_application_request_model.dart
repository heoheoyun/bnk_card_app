import '../../domain/entities/credit_application.dart'
    show CreditApplicantSnapshot, PaymentSnapshot;

class CreditApplicationRequestModel {

  // STEP 1 - 약관 동의
  static Map<String, dynamic> step1ToJson({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) {
    return {
      'cardId':      cardId,
      'agreedTerms': agreedTerms,
    };
  }

  // STEP 2 - 본인확인
  static Map<String, dynamic> step2ToJson({
    required int    creditAppId,
    required String idType,
    required String idName,
    required String idResidentNo,
    required String idAddress,
    required String idIssueDate,
  }) {
    return {
      'creditAppId':  creditAppId,
      'idType':       idType,
      'idName':       idName,
      'idResidentNo': idResidentNo,
      'idAddress':    idAddress,
      'idIssueDate':  idIssueDate,
    };
  }

  // STEP 3 - 기본정보 + 직업/소득
  static Map<String, dynamic> step3ToJson({
    required int                    creditAppId,
    required CreditApplicantSnapshot applicantSnapshot,
    required String                 annualIncomeBand,
    required String                 creditScoreBand,
    required int                    linkedAccountId,
  }) {
    return {
      'creditAppId':       creditAppId,
      'applicantSnapshot': {
        'name':                applicantSnapshot.name,
        'nameEn':              applicantSnapshot.nameEn,
        'mobileNo':            applicantSnapshot.mobileNo,
        'address':             applicantSnapshot.address,
        'email':               applicantSnapshot.email,
        'incomeType':          applicantSnapshot.incomeType,
        'healthInsuranceType': applicantSnapshot.healthInsuranceType,
        'hasRealEstate':       applicantSnapshot.hasRealEstate,
        'hasOwnVehicle':       applicantSnapshot.hasOwnVehicle,
      },
      'annualIncomeBand': annualIncomeBand,
      'creditScoreBand':  creditScoreBand,
      'linkedAccountId':  linkedAccountId,
    };
  }

  // STEP 4+5 - 결제정보 + 서류(신규고객) + 신청 완료
  static Map<String, dynamic> step4ToJson({
    required int             creditAppId,
    required PaymentSnapshot paymentSnapshot,
    required int             requestedLimit,
    required String          cardPassword,
    String? incomeDocKey,
    String? assetDocKey,
    String? jobDocKey,
  }) {
    return {
      'creditAppId':      creditAppId,
      'paymentSnapshot': {
        'cardBrand':         paymentSnapshot.cardBrand,
        'cardDesignId':      paymentSnapshot.cardDesignId,
        'paymentDay':        paymentSnapshot.paymentDay,
        'combinedTransitYn': paymentSnapshot.combinedTransitYn,
        'txAlertType':       paymentSnapshot.txAlertType,
        'statementMethod':   paymentSnapshot.statementMethod,
      },
      'requestedLimit': requestedLimit,
      'cardPassword':   cardPassword,
      'incomeDocKey':   incomeDocKey,
      'assetDocKey':    assetDocKey,
      'jobDocKey':      jobDocKey,
    };
  }
}