import 'package:bnk_card_app/core/network/dio_client.dart';

/// 계좌 원격 데이터소스. GET /api/accounts/me 호출.
class AccountRemoteDatasource {
  final _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> getMyAccounts() async {
    final res = await _dio.get('/api/accounts/me');
    return (res.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}