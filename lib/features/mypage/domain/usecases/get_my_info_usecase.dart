import '../repositories/mypage_repository.dart';
class GetMyInfoUsecase {
  final MypageRepository _repo;
  GetMyInfoUsecase(this._repo);
  Future<Map<String, dynamic>> call() => _repo.getMyInfo();
}
