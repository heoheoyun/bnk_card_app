import '../repositories/auth_repository.dart';
class FindIdUsecase {
  final AuthRepository _repo;
  FindIdUsecase(this._repo);
  Future<Map<String, String>> call(String name, String phone) => _repo.findId(name, phone);
}
