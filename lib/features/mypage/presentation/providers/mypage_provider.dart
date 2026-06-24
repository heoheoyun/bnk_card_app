import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/mypage_remote_datasource.dart';

final mypageDatasourceProvider = Provider<MypageRemoteDatasource>(
      (_) => MypageRemoteDatasource(),
);

final myInfoProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getMyInfo();
});

final myCardsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getMyCards();
});

final monthlySpendingProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getMonthlySpending();
});