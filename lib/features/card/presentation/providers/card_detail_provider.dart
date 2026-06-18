import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'card_list_provider.dart';

final cardDetailProvider = FutureProvider.family<Map<String, dynamic>, int>(
      (ref, cardId) => ref.watch(cardRepositoryProvider).getCardDetail(cardId),
);