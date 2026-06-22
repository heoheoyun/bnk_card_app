import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/mypage_provider.dart';

class SpendingInputPage extends ConsumerStatefulWidget {
  const SpendingInputPage({super.key});

  @override
  ConsumerState<SpendingInputPage> createState() => _SpendingInputPageState();
}

class _SpendingInputPageState extends ConsumerState<SpendingInputPage> {
  static const _categories = [
    {'code': 'FOOD', 'label': '식음료/카페'},
    {'code': 'SHOPPING', 'label': '쇼핑'},
    {'code': 'TRANSPORT', 'label': '교통/대중교통'},
    {'code': 'OIL', 'label': '주유/충전'},
    {'code': 'LEISURE', 'label': '여가/문화'},
    {'code': 'TELECOM', 'label': '통신/휴대폰'},
    {'code': 'MEDICAL', 'label': '의료/건강'},
    {'code': 'EDUCATION', 'label': '교육'},
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final c in _categories) c['code']!: TextEditingController(text: '0'),
  };

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final ds = ref.read(mypageDatasourceProvider);
      final items = await ds.getSpendingPatterns();
      for (final item in items) {
        final code = item['categoryCode'] as String?;
        final amount = item['monthlyAmount'];
        if (code != null && _controllers.containsKey(code)) {
          _controllers[code]!.text = (amount ?? 0).toString();
        }
      }
    } catch (_) {
      // 기존 데이터 없으면 0으로 시작
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _total => _controllers.values
      .map((c) => int.tryParse(c.text) ?? 0)
      .fold(0, (a, b) => a + b);

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final ds = ref.read(mypageDatasourceProvider);
      final items = _categories
          .map((c) => {
        'categoryCode': c['code'],
        'monthlyAmount': int.tryParse(_controllers[c['code']]!.text) ?? 0,
        'source': 'MANUAL',
      })
          .toList();
      await ds.saveSpendingPatterns(items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('소비 패턴이 저장되었습니다.')),
        );
        context.go('/mypage');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.gray800,
        title: const Text('소비 패턴 관리',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.teal50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '입력한 금액은 수동(MANUAL) 출처로 저장되며 AI 카드 추천에 즉시 반영됩니다.',
              style: TextStyle(fontSize: 12, color: AppColors.teal800, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: _categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.teal600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Text(c['label']!,
                            style: const TextStyle(fontSize: 13, color: AppColors.gray800)),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _controllers[c['code']],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            suffixText: '원',
                            suffixStyle: const TextStyle(
                                fontSize: 11, color: AppColors.gray400),
                            filled: true,
                            fillColor: AppColors.gray100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('월 합계',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                Text('${_total.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]},',
                )}원',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.teal800)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text('저장하기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}