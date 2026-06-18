import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/search_remote_datasource.dart';

final searchDatasourceProvider = Provider<SearchRemoteDatasource>(
      (_) => SearchRemoteDatasource(),
);

class SearchNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SearchRemoteDatasource _ds;
  SearchNotifier(this._ds) : super(const AsyncData(null));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _ds.search(query));
  }

  void clear() => state = const AsyncData(null);
}

final searchProvider =
StateNotifierProvider<SearchNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) => SearchNotifier(ref.watch(searchDatasourceProvider)),
);

final popularKeywordsProvider = FutureProvider<List<dynamic>>((ref) {
  final ds = ref.watch(searchDatasourceProvider);
  return ds.getPopularKeywords();
});

final suggestKeywordsProvider = FutureProvider<List<dynamic>>((ref) {
  final ds = ref.watch(searchDatasourceProvider);
  return ds.getSuggestKeywords();
});