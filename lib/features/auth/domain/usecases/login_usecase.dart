import '../repositories/auth_repository.dart';
class LoginUsecase {
  final AuthRepository _repo;
  LoginUsecase(this._repo);
  Future<void> call(String email, String password) => _repo.login(email, password);
}
