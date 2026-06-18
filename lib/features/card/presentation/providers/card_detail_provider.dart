import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_detail.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/datasource/card_remote_datasource.dart';

/// 카드 상세 Provider — cardId 별 캐싱 (FutureProvider.family)
///
/// [CardDetail] Entity를 반환하므로 Presentation 레이어에서
/// Map 타입 직접 접근을 제거하고 타입 안전성을 보장한다.
final cardDetailProvider =
FutureProvider.family<CardDetail, int>((ref, cardId) {
  final repo = CardRepositoryImpl(CardRemoteDatasource());
  return repo.getCardDetail(cardId);
});