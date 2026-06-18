import '../repositories/auth_repository.dart';
class ConfirmEmailUsecase {
  final AuthRepository _repo;
  ConfirmEmailUsecase(this._repo);
  Future<void> call(String email, String code) => _repo.verifyEmail(email, code);
}
