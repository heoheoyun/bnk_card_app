import '../repositories/mypage_repository.dart';
class ChangePasswordUsecase {
  final MypageRepository _repo;
  ChangePasswordUsecase(this._repo);
  Future<void> call(String current, String newPassword) => _repo.changePassword(current, newPassword);
}
