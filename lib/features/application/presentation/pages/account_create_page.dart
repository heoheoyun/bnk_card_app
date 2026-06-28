import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../providers/account_provider.dart';

/// 계좌 개설 화면.
/// 서버 계약: POST /api/accounts  body { accountType, accountAlias?, password }
/// 성공 시 myAccountsProvider 를 무효화하여 내 계좌 목록을 갱신한다.
class AccountCreatePage extends ConsumerStatefulWidget {
  const AccountCreatePage({super.key});

  @override
  ConsumerState<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends ConsumerState<AccountCreatePage> {
  String _accountType = 'CHECKING';
  final _aliasCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  bool _isLoading = false;

  static const _types = {
    'CHECKING': '입출금',
    'SAVINGS': '적금',
    'DEPOSIT': '예금',
  };

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _passwordCtrl.text.length >= 4 &&
      _passwordCtrl.text.length <= 6 &&
      _passwordCtrl.text == _password2Ctrl.text;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await DioClient.instance.post(
        '/api/accounts',
        data: {
          'accountType': _accountType,
          'accountAlias':
              _aliasCtrl.text.trim().isEmpty ? null : _aliasCtrl.text.trim(),
          'password': _passwordCtrl.text,
        },
      );

      // 목록 갱신
      ref.invalidate(myAccountsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계좌가 개설되었습니다.')),
        );
        // 이전 화면으로 복귀 (카드 신청 step3 등에서 진입한 경우 그 흐름으로 복귀)
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/mypage/accounts');
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계좌 개설에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '계좌 개설'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '새 계좌 개설',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '카드 신청·결제에 연결할 계좌를 만듭니다.',
                      style: TextStyle(fontSize: 13, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 24),

                    // 계좌 종류
                    const Text('계좌 종류',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _types.entries.map((e) {
                        final selected = _accountType == e.key;
                        return GestureDetector(
                          onTap: () => setState(() => _accountType = e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.teal600 : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? AppColors.teal600
                                    : AppColors.gray200,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    selected ? Colors.white : AppColors.gray600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // 계좌 별칭 (선택)
                    const Text('계좌 별칭 (선택)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aliasCtrl,
                      maxLength: 20,
                      decoration: _dec(hint: '예) 월급통장'),
                    ),
                    const SizedBox(height: 12),

                    // 계좌 비밀번호
                    const Text('계좌 비밀번호 (숫자 4~6자리)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec(hint: '숫자 4~6자리'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password2Ctrl,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: _dec(hint: '비밀번호 확인'),
                    ),
                    if (_password2Ctrl.text.isNotEmpty &&
                        _passwordCtrl.text != _password2Ctrl.text) ...[
                      const SizedBox(height: 6),
                      const Text(
                        '비밀번호가 일치하지 않습니다.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label: '계좌 개설',
                isLoading: _isLoading,
                onPressed: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal600),
        ),
      );
}
