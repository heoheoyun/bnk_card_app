import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/mypage_provider.dart';

/// #6 소비 패턴 수동 입력.
/// 서버 계약에 맞춰 categoryId 기반으로 동작한다.
///  - 카테고리: GET /api/cards/categories ({categoryId, categoryName})
///  - 조회: GET /api/users/me/spending ({categoryId, monthlyAmount})
///  - 저장: PUT /api/users/me/spending ({patterns:[{categoryId, monthlyAmount}]})
class SpendingInputPage extends ConsumerStatefulWidget {
  const SpendingInputPage({super.key});

  @override
  ConsumerState<SpendingInputPage> createState() => _SpendingInputPageState();
}

class _SpendingInputPageState extends ConsumerState<SpendingInputPage> {
  // [{categoryId, categoryName}, ...]
  List<Map<String, dynamic>> _cats = [];
  // categoryId → 입력 컨트롤러
  final Map<int, TextEditingController> _controllers = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = ref.read(mypageDatasourceProvider);

      // 1) 카테고리 목록 (id 기반 렌더)
      final cats = await ds.getCardCategories();
      _cats = cats;
      for (final c in cats) {
        final id = (c['categoryId'] as num).toInt();
        _controllers[id] = TextEditingController(text: '0');
      }

      // 2) 기존 입력값 채우기 (categoryId 매칭)
      final items = await ds.getSpendingPatterns();
      for (final it in items) {
        final id = (it['categoryId'] as num?)?.toInt();
        final amt = (it['monthlyAmount'] as num?)?.toInt() ?? 0;
        if (id != null && _controllers.containsKey(id)) {
          _controllers[id]!.text = amt.toString();
        }
      }
    } catch (_) {
      // 카테고리/기존값 로드 실패 → 빈 값으로 시작
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
      final patterns = _controllers.entries
          .map((e) => {
        'categoryId': e.key,
        'monthlyAmount': int.tryParse(e.value.text) ?? 0,
      })
          .toList();
      await ds.saveSpendingPatterns(patterns);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('소비 패턴이 저장되었습니다.')),
        );
        context.go('/mypage');
      }
    } catch (_) {
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
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _comma(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );

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
              style: TextStyle(
                  fontSize: 12, color: AppColors.teal800, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: _cats.map((c) {
                final id = (c['categoryId'] as num).toInt();
                final name = c['categoryName'] as String? ?? '카테고리';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.teal600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.gray800)),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _controllers[id],
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
                    style: TextStyle(
                        fontSize: 13, color: AppColors.gray600)),
                Text('${_comma(_total)}원',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal800)),
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
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text('저장하기',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}