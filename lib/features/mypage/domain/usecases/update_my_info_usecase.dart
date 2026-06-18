import '../repositories/mypage_repository.dart';
class UpdateMyInfoUsecase {
  final MypageRepository _repo;
  UpdateMyInfoUsecase(this._repo);
  Future<void> call(String name, String phone) => _repo.updateMyInfo(name, phone);
}
