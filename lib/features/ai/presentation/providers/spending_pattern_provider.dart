import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/ai_remote_datasource.dart';
import '../../data/models/spending_pattern_model.dart';

// datasource를 독립적으로 선언 (chat_provider 의존 제거)
final spendingDatasourceProvider = Provider<AiRemoteDatasource>(
      (_) => AiRemoteDatasource(),
);

final mySpendingProvider = FutureProvider<List<SpendingPatternModel>>((ref) async {
  final ds = ref.watch(spendingDatasourceProvider);
  final list = await ds.getMySpending();
  return list
      .map((e) => SpendingPatternModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
});