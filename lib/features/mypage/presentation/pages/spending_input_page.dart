import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../../presentation/providers/mypage_provider.dart';

class SpendingInputPage extends ConsumerStatefulWidget {
  const SpendingInputPage({super.key});

  @override
  ConsumerState<SpendingInputPage> createState() =>
      _SpendingInputPageState();
}

class _SpendingInputPageState extends ConsumerState<SpendingInputPage> {
  final Map<int, TextEditingController> _controllers = {};
  bool _isLoading  = false;
  bool _isFetching = true; // 기존 데이터 로드 중

  /// categoryId → categoryCode 매핑 (서버 응답 key 대응)
  static const _categories = [
    (id: 1,  code: 'FOOD',          label: '식비',        icon: Icons.restaurant_outlined),
    (id: 2,  code: 'TRANSPORT',     label: '교통',        icon: Icons.directions_bus_outlined),
    (id: 3,  code: 'SHOPPING',      label: '쇼핑',        icon: Icons.shopping_bag_outlined),
    (id: 4,  code: 'HEALTH',        label: '의료/약국',   icon: Icons.local_hospital_outlined),
    (id: 5,  code: 'CULTURE',       label: '여가/문화',   icon: Icons.movie_outlined),
    (id: 6,  code: 'EDUCATION',     label: '카페/디저트', icon: Icons.coffee_outlined),
    (id: 7,  code: 'COMMUNICATION', label: '주유',        icon: Icons.local_gas_station_outlined),
    (id: 8,  code: 'INSURANCE',     label: '통신',        icon: Icons.phone_android_outlined),
    (id: 9,  code: 'HOUSING',       label: '여행/숙박',   icon: Icons.hotel_outlined),
    (id: 10, code: 'ETC',           label: '편의점',      icon: Icons.store_outlined),
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _categories) {
      _controllers[c.id] = TextEditingController();
    }
    _loadExisting();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  // ── 기존 저장 데이터 프리로드 ──────────────────────────────────
  Future<void> _loadExisting() async {
    try {
      final ds = ref.read(mypageDatasourceProvider);
      final list = await ds.getSpendingPatterns();
      // categoryId 또는 categoryCode 기준으로 컨트롤러에 주입
      final byId   = <int, int>{};
      final byCode = <String, int>{};
      for (final item in list) {
        final id     = item['categoryId'] as int?;
        final code   = item['categoryCode'] as String?;
        final amount = (item['monthlyAmount'] as num?)?.toInt() ?? 0;
        if (id   != null) byId[id]     = amount;
        if (code != null) byCode[code] = amount;
      }
      for (final cat in _categories) {
        final amount = byId[cat.id] ?? byCode[cat.code] ?? 0;
        if (amount > 0) {
          _controllers[cat.id]?.text = amount.toString();
        }
      }
    } catch (_) {
      // 로드 실패 시 빈 값으로 진행 (신규 입력과 동일)
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // ── 저장 ──────────────────────────────────────────────────────
  Future<void> _save() async {
    final items = <Map<String, dynamic>>[];
    for (final cat in _categories) {
      final raw    = _controllers[cat.id]?.text.replaceAll(',', '') ?? '';
      final amount = int.tryParse(raw) ?? 0;
      if (amount > 0) {
        items.add({'categoryId': cat.id, 'monthlyAmount': amount});
      }
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개 카테고리의 금액을 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ds = ref.read(mypageDatasourceProvider);
      await ds.saveSpendingPatterns(items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('소비 패턴이 저장되었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
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
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '월 평균 지출 금액을 입력해 주세요.\nAI가 최적의 카드를 추천해 드립니다.',
              style: const TextStyle(
                color: AppColors.textMuted,
                height: 1.5,
                fontSize: 14,
              ),
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
                      Icon(cat.icon,
                          size: 22, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(cat.label,
                            style: const TextStyle(fontSize: 14)),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            suffixText: '원',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
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
              padding:
              const EdgeInsets.fromLTRB(16, 8, 16, 16),
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