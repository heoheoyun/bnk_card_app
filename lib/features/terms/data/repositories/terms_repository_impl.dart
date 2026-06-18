import '../../domain/repositories/terms_repository.dart';
import '../datasource/terms_remote_datasource.dart';

class TermsRepositoryImpl implements TermsRepository {
  final TermsRemoteDatasource _ds;
  TermsRepositoryImpl(this._ds);

  @override Future<List<Map<String, dynamic>>> getTermsPackage(String packageType) async {
    final list = await _ds.getTermsPackage(packageType);
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<void> agreeTerms(List<Map<String, dynamic>> agreements) => _ds.agreeTerms(agreements);
}
