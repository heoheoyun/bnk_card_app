import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/terms_remote_datasource.dart';

final termsDatasourceProvider = Provider<TermsRemoteDatasource>(
      (_) => TermsRemoteDatasource(),
);

final termsPackageProvider =
FutureProvider.family<List<dynamic>, String>((ref, packageType) {
  final ds = ref.watch(termsDatasourceProvider);
  return ds.getTermsPackage(packageType);
});

// 동의 체크 상태 Map<termsId, agreed>
class TermsAgreeNotifier extends StateNotifier<Map<int, bool>> {
  TermsAgreeNotifier() : super({});

  void toggle(int termsId) {
    state = {...state, termsId: !(state[termsId] ?? false)};
  }

  void agreeAll(List<int> ids) {
    state = {for (final id in ids) id: true};
  }

  bool isAllAgreed(List<int> requiredIds) {
    return requiredIds.every((id) => state[id] == true);
  }
}

final termsAgreeProvider =
StateNotifierProvider<TermsAgreeNotifier, Map<int, bool>>(
      (_) => TermsAgreeNotifier(),
);

final termsFilesProvider =
FutureProvider.family<List<dynamic>, int>((ref, termsId) {
  final ds = ref.watch(termsDatasourceProvider);
  return ds.getTermsFiles(termsId);
});