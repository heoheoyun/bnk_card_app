import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class TermsRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<List<dynamic>> getTermsPackage(String packageType) async {
    final res = await _dio.get(ApiPaths.termsPackage(packageType));
    return res.data['data'] as List<dynamic>;
  }

  Future<void> agreeTerms(List<Map<String, dynamic>> agreements) async {
    await _dio.post('/api/terms/agree', data: {'agreements': agreements});
  }
}
