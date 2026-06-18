import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/home_remote_datasource.dart';

final homeDatasourceProvider = Provider<HomeRemoteDatasource>(
      (_) => HomeRemoteDatasource(),
);

final homeBannersProvider = FutureProvider<List<dynamic>>((ref) {
  final ds = ref.watch(homeDatasourceProvider);
  return ds.getHomeBanners();
});

final homeTop3Provider = FutureProvider.family<List<dynamic>, String?>(
      (ref, surveyResult) {
    final ds = ref.watch(homeDatasourceProvider);
    return ds.getTop3Cards(surveyResult: surveyResult);
  },
);

final cardCategoriesProvider = FutureProvider<List<dynamic>>((ref) {
  final ds = ref.watch(homeDatasourceProvider);
  return ds.getCardCategories();
});

// 혜택 시뮬레이션
class SimulationNotifier extends StateNotifier<AsyncValue<List<dynamic>?>> {
  final HomeRemoteDatasource _ds;
  SimulationNotifier(this._ds) : super(const AsyncData(null));

  Future<void> simulate(List<int> cardIds, Map<int, int> categoryAmounts) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => _ds.simulateBenefits(cardIds, categoryAmounts),
    );
  }

  void reset() => state = const AsyncData(null);
}

final simulationProvider =
StateNotifierProvider<SimulationNotifier, AsyncValue<List<dynamic>?>>(
      (ref) => SimulationNotifier(ref.watch(homeDatasourceProvider)),
);