import '../repositories/auth_repository.dart';
import '../../data/models/signup_request_model.dart';

class SignupUsecase {
  final AuthRepository _repo;
  SignupUsecase(this._repo);
  Future<int> call(SignupRequestModel req) => _repo.signup(req);
}