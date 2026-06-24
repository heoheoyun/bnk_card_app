import '../../domain/entities/credit_application.dart' show PaymentSnapshot;

class PaymentSnapshotModel {
  static PaymentSnapshot fromJson(Map<String, dynamic> json) {
    return PaymentSnapshot(
      cardBrand:         json['cardBrand']         as String?,
      cardDesignId:      json['cardDesignId']      as String?,
      paymentDay:        json['paymentDay']        as int?,
      combinedTransitYn: json['combinedTransitYn'] as String?,
      txAlertType:       json['txAlertType']       as String?,
      statementMethod:   json['statementMethod']   as String?,
    );
  }
}