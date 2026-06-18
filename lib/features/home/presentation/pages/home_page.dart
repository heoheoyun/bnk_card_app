import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/top3_card_section.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../../../../shared/widgets/bnk_error_view.dart';
import '../../data/models/banner_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(homeBannersProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: 'BNK 카드', showBack: false),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeBannersProvider);
          ref.invalidate(homeTop3Provider(null));
        },
        child: bannersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => BnkErrorView(
            message: '홈 화면을 불러오지 못했습니다.',
            onRetry: () => ref.invalidate(homeBannersProvider),
          ),
          data: (banners) => ListView(
            children: [
              BannerCarousel(
                banners: banners
                    .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e as Map)))
                    .toList(),
              ),
              const Top3CardSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 0),
    );
  }
}