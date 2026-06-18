import 'package:flutter_riverpod/flutter_riverpod.dart';

// 비교 목록 (최대 3개) 로컬 상태
class CardCompareNotifier extends StateNotifier<List<int>> {
  CardCompareNotifier() : super([]);

  bool toggle(int cardId) {
    if (state.contains(cardId)) {
      state = state.where((id) => id != cardId).toList();
      return false;
    }
    if (state.length >= 3) return false;
    state = [...state, cardId];
    return true;
  }

  void clear() => state = [];
}

final cardCompareProvider = StateNotifierProvider<CardCompareNotifier, List<int>>((_) => CardCompareNotifier());
