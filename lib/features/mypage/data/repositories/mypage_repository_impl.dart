import '../../domain/repositories/mypage_repository.dart';
import '../datasource/mypage_remote_datasource.dart';

class MypageRepositoryImpl implements MypageRepository {
  final MypageRemoteDatasource _ds;
  MypageRepositoryImpl(this._ds);

  @override Future<Map<String, dynamic>> getMyInfo() => _ds.getMyInfo();

  @override Future<void> updateMyInfo(String name, String phone) =>
      _ds.updateMyInfo({'name': name, 'phone': phone});

  // datasource.changePassword 가 3개 인자(현재/새/새 확인)를 기대하므로 맞춤.
  // 인터페이스(mypage_repository.dart)와 호출부도 3-인자로 통일해야 함.
  @override Future<void> changePassword(
      String current,
      String newPassword,
      String confirmPassword,
      ) =>
      _ds.changePassword(current, newPassword, confirmPassword);
}