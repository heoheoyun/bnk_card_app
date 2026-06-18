import '../repositories/auth_repository.dart';
class SignupUsecase {
  final AuthRepository _repo;
  SignupUsecase(this._repo);
  Future<int> call(String email, String password, String name, String phone) =>
      _repo.signup(email, password, name, phone);
}
