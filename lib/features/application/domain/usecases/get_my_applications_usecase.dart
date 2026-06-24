import '../entities/credit_application.dart';
import '../entities/check_application.dart';
import '../repositories/credit_application_repository.dart';
import '../repositories/check_application_repository.dart';

class GetMyApplicationsUsecase {
  final CreditApplicationRepository _creditRepo;
  final CheckApplicationRepository  _checkRepo;

  GetMyApplicationsUsecase(this._creditRepo, this._checkRepo);

  Future<Map<String, dynamic>> call() async {
    final results = await Future.wait([
      _creditRepo.getMyApplications(),
      _checkRepo.getMyApplications(),
    ]);

    return {
      'creditApplications': results[0] as List<CreditApplication>,
      'checkApplications':  results[1] as List<CheckApplication>,
    };
  }
}