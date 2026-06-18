import '../repositories/auth_repository.dart';
class LogoutUsecase {
  final AuthRepository _repo;
  LogoutUsecase(this._repo);
  Future<void> call() => _repo.logout();
}
