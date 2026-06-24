import '../../domain/entities/credit_application.dart' show CreditApplicantSnapshot;
import '../../domain/entities/check_application.dart' show CheckApplicantSnapshot;

class ApplicantSnapshotModel {

  static CreditApplicantSnapshot creditFromJson(Map<String, dynamic> json) {
    return CreditApplicantSnapshot(
      name:                json['name']                as String,
      nameEn:              json['nameEn']              as String?,
      mobileNo:            json['mobileNo']            as String,
      address:             json['address']             as String,
      email:               json['email']               as String,
      incomeType:          json['incomeType']          as String?,
      healthInsuranceType: json['healthInsuranceType'] as String?,
      hasRealEstate:       json['hasRealEstate']       as String?,
      hasOwnVehicle:       json['hasOwnVehicle']       as String?,
    );
  }

  static CheckApplicantSnapshot checkFromJson(Map<String, dynamic> json) {
    return CheckApplicantSnapshot(
      name:               json['name']               as String,
      nameEn:             json['nameEn']             as String?,
      mobileNo:           json['mobileNo']           as String,
      address:            json['address']            as String,
      email:              json['email']              as String,
      jobType:            json['jobType']            as String?,
      transactionPurpose: json['transactionPurpose'] as String?,
      fundSource:         json['fundSource']         as String?,
    );
  }
}