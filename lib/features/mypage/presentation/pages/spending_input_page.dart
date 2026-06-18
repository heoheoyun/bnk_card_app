import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';

class SpendingInputPage extends ConsumerStatefulWidget {
  const SpendingInputPage({super.key});

  @override
  ConsumerState<SpendingInputPage> createState() =>
      _SpendingInputPageState();
}

class _SpendingInputPageState extends ConsumerState<SpendingInputPage> {
  final Map<int, TextEditingController> _controllers = {};
  bool _isLoading = false;

  static const _categories = [
    (id: 1,  label: '식비',        icon: Icons.restaurant_outlined),
    (id: 2,  label: '교통',        icon: Icons.directions_bus_outlined),
    (id: 3,  label: '쇼핑',        icon: Icons.shopping_bag_outlined),
    (id: 4,  label: '의료/약국',    icon: Icons.local_hospital_outlined),
    (id: 5,  label: '여가/문화',    icon: Icons.movie_outlined),
    (id: 6,  label: '카페/디저트',  icon: Icons.coffee_outlined),
    (id: 7,  label: '주유',        icon: Icons.local_gas_station_outlined),
    (id: 8,  label: '통신',        icon: Icons.phone_android_outlined),
    (id: 9,  label: '여행/숙박',    icon: Icons.hotel_outlined),
    (id: 10, label: '편의점',       icon: Icons.store_outlined),
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _categories) {
      _controllers[c.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final amounts = <int, int>{};
    for (final c in _categories) {
      final raw    = _controllers[c.id]?.text.replaceAll(',', '') ?? '';
      final amount = int.tryParse(raw) ?? 0;
      if (amount > 0) amounts[c.id] = amount;
    }
    if (amounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('최소 1개 카테고리의 금액을 입력해 주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // TODO: POST /api/users/me/spending
      // await ref.read(myPageDatasourceProvider).saveSpending(amounts);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('소비 패턴이 저장되었습니다.'),
              backgroundColor: AppColors.primary),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BnkAppBar(title: '소비 패턴 등록'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '월 평균 지출 금액을 입력해 주세요.\nAI가 최적의 카드를 추천해 드립니다.',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  height: 1.5,
                  fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat  = _categories[i];
                final ctrl = _controllers[cat.id]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.icon,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Text(cat.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            suffixText: '원',
                            hintText: '0',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label: '저장하기',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}