abstract class MypageRepository {
  Future<Map<String, dynamic>> getMyInfo();
  Future<void> updateMyInfo(String name, String phone);
  Future<void> changePassword(String current, String newPassword);
}
