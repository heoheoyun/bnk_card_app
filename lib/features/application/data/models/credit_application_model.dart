import '../../domain/entities/credit_application.dart';
import 'applicant_snapshot_model.dart';
import 'payment_snapshot_model.dart';

class CreditApplicationModel {
  static CreditApplication fromJson(Map<String, dynamic> json) {
    return CreditApplication(
      creditAppId:       json['creditAppId'] as int,
      cardId:            json['cardId'] as int,
      cardName:          json['cardName'] as String?,
      cardImageUrl:      json['cardImageUrl'] as String?,
      applicationStatus: ApplicationStatus.fromString(json['applicationStatus'] as String),
      idVerifiedYn: json['idVerifiedYn'] as String?,
      applicantSnapshot: json['applicantSnapshot'] != null
          ? ApplicantSnapshotModel.creditFromJson(json['applicantSnapshot'])
          : null,
      paymentSnapshot:   json['paymentSnapshot'] != null
          ? PaymentSnapshotModel.fromJson(json['paymentSnapshot'])
          : null,
      annualIncomeBand: json['annualIncomeBand'] as String?,
      creditScoreBand:  json['creditScoreBand']  as String?,
      linkedAccountId:  json['linkedAccountId'] != null
          ? (json['linkedAccountId'] as num).toInt()
          : null,
      approvedLimit:     json['approvedLimit'] as int?,
      requestedLimit:    json['requestedLimit'] as int?,
      rejectionReason:   json['rejectionReason'] as String?,
      limitCheckResult:  json['limitCheckResult'] as String?,
      appliedAt:         json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
      createdAt:         json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}