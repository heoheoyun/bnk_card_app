import '../repositories/auth_repository.dart';
class SendEmailVerifyUsecase {
  final AuthRepository _repo;
  SendEmailVerifyUsecase(this._repo);
  Future<void> call(String email) => _repo.sendVerifyCode(email);
}
