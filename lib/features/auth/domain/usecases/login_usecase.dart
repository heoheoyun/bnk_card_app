import '../repositories/auth_repository.dart';
import '../../data/models/login_result.dart';

class LoginUsecase {
  final AuthRepository _repo;
  LoginUsecase(this._repo);
  Future<LoginResult> call(String email, String password) =>
      _repo.login(email, password);
}