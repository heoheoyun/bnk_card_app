import '../../domain/repositories/mypage_repository.dart';
import '../datasource/mypage_remote_datasource.dart';

class MypageRepositoryImpl implements MypageRepository {
  final MypageRemoteDatasource _ds;
  MypageRepositoryImpl(this._ds);

  @override Future<Map<String, dynamic>> getMyInfo()   => _ds.getMyInfo();
  @override Future<void> updateMyInfo(String name, String phone) =>
      _ds.updateMyInfo({'name': name, 'phone': phone});
  @override Future<void> changePassword(String current, String newPassword) =>
      _ds.changePassword(current, newPassword);
}
