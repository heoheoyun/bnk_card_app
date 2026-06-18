import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/card_remote_datasource.dart';

/// 카드 상세 데이터 Provider — cardId 별 캐싱 (FutureProvider.family)
///
/// card_list_provider 의 cardDatasourceProvider 와 이름 충돌을 피하기 위해
/// CardRemoteDatasource 를 직접 인스턴스화하여 사용한다.
final cardDetailProvider =
FutureProvider.family<Map<String, dynamic>, int>((ref, cardId) {
  return CardRemoteDatasource().getCardDetail(cardId);
});