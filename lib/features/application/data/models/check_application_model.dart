import '../../domain/entities/check_application.dart';
import '../../domain/entities/credit_application.dart' show ApplicationStatus;
import 'applicant_snapshot_model.dart';
import 'payment_snapshot_model.dart';

class CheckApplicationModel {
  static CheckApplication fromJson(Map<String, dynamic> json) {
    return CheckApplication(
      checkAppId:        json['checkAppId'] as int,
      cardId:            json['cardId'] as int,
      cardName:          json['cardName'] as String?,
      cardImageUrl:      json['cardImageUrl'] as String?,
      applicationStatus: ApplicationStatus.fromString(json['applicationStatus'] as String),
      idVerifiedYn: json['idVerifiedYn'] as String?,
      applicantSnapshot: json['applicantSnapshot'] != null
          ? ApplicantSnapshotModel.checkFromJson(json['applicantSnapshot'])
          : null,
      paymentSnapshot:   json['paymentSnapshot'] != null
          ? PaymentSnapshotModel.fromJson(json['paymentSnapshot'])
          : null,
      linkedAccountId:   json['linkedAccountId'] as int?,
      rejectionReason:   json['rejectionReason'] as String?,
      appliedAt:         json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
      createdAt:         json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}