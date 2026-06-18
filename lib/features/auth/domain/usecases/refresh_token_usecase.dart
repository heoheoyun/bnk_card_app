import '../repositories/auth_repository.dart';
class RefreshTokenUsecase {
  final AuthRepository _repo;
  RefreshTokenUsecase(this._repo);
  Future<void> call() => _repo.refreshToken();
}
