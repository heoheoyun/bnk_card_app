import '../repositories/auth_repository.dart';
class ResetPasswordUsecase {
  final AuthRepository _repo;
  ResetPasswordUsecase(this._repo);
  Future<void> call(String email, String token, String newPassword) =>
      _repo.resetPassword(email, token, newPassword);
}
