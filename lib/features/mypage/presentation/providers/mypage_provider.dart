import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/domain/entities/user_card.dart';
import '../../data/datasource/mypage_remote_datasource.dart';
import '../../data/models/trusted_ip_model.dart';
import '../../data/models/address_model.dart';

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

/// 보유 카드 단건 상세 (userCardId 별 캐시). 카드 관리 화면에서 사용.
final userCardProvider =
    FutureProvider.family<UserCard, int>((ref, userCardId) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getUserCard(userCardId);
});

final monthlySpendingProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getMonthlySpending();
});

/// 신뢰 기기(IP) 목록. 별명 수정/삭제 후 invalidate 로 갱신한다.
final trustedIpsProvider = FutureProvider<List<TrustedIp>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getTrustedIps();
});

/// 주소록(배송지) 목록. 등록/수정/삭제 후 invalidate 로 갱신한다.
final addressesProvider = FutureProvider<List<Address>>((ref) {
  final ds = ref.watch(mypageDatasourceProvider);
  return ds.getAddresses();
});