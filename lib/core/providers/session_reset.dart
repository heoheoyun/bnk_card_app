import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/mypage/presentation/providers/mypage_provider.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/notification/presentation/providers/notification_provider.dart';
import '../../features/application/presentation/providers/account_provider.dart';
import '../../features/application/presentation/providers/my_applications_provider.dart';

/// 계정 전환(로그인/로그아웃) 시 이전 사용자 데이터가 화면에 남는 문제를 막기 위해
/// 사용자 범위(user-scoped) 캐시 provider 들을 일괄 무효화한다.
///
/// 이 provider 들은 autoDispose 가 아니라 앱 생명주기 동안 캐시를 유지하므로,
/// 계정이 바뀌어도 명시적으로 invalidate 하지 않으면 직전 사용자의
/// 마이페이지·홈·알림 데이터가 그대로 노출된다.
void invalidateUserScopedData(Ref ref) {
  // 마이페이지
  ref.invalidate(myInfoProvider);
  ref.invalidate(myCardsProvider);
  ref.invalidate(monthlySpendingProvider);
  ref.invalidate(trustedIpsProvider);
  ref.invalidate(addressesProvider);
  // 홈
  ref.invalidate(homeBannersProvider);
  ref.invalidate(homeTop3Provider);
  ref.invalidate(cardCategoriesProvider);
  // 알림
  ref.invalidate(notificationListProvider);
  ref.invalidate(unreadCountProvider);
  // 계좌 / 신청
  ref.invalidate(myAccountsProvider);
  ref.invalidate(myApplicationsProvider);
}
