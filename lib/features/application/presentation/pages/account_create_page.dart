import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../providers/account_provider.dart';

class AccountCreatePage extends ConsumerStatefulWidget {
  const AccountCreatePage({super.key});

  @override
  ConsumerState<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends ConsumerState<AccountCreatePage> {
  String  _accountType  = 'CHECKING';
  final _aliasCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _password2Ctrl  = TextEditingController();
  bool    _isLoading    = false;

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
          'accountType':  _accountType,
          'accountAlias': _aliasCtrl.text.trim().isEmpty
              ? null
              : _aliasCtrl.text.trim(),
          'password':     _passwordCtrl.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계좌가 개설되었습니다.')),
        );
        ref.invalidate(myAccountsProvider);
        context.pop(); // 이전 페이지(step3 or step4)로 복귀
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계좌 개설에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BnkAppBar(title: '계좌 개설'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계좌 종류',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...{
                    'CHECKING': '입출금 통장',
                    'SAVINGS':  '적금',
                    'DEPOSIT':  '예금',
                  }.entries.map((e) => RadioListTile<String>(
                    value:        e.key,
                    groupValue:   _accountType,
                    onChanged:    (v) => setState(() => _accountType = v!),
                    title:        Text(e.value),
                    activeColor:  AppColors.teal600,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const SizedBox(height: 20),

                  const Text(
                    '계좌 별명 (선택)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aliasCtrl,
                    decoration: _inputDecoration(hint: '예: 생활비 통장'),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '출금 비밀번호',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller:   _passwordCtrl,
                    obscureText:  true,
                    maxLength:    6,
                    keyboardType: TextInputType.number,
                    onChanged:    (_) => setState(() {}),
                    decoration:   _inputDecoration(hint: '4~6자리 숫자'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:   _password2Ctrl,
                    obscureText:  true,
                    maxLength:    6,
                    keyboardType: TextInputType.number,
                    onChanged:    (_) => setState(() {}),
                    decoration:   _inputDecoration(hint: '비밀번호 확인'),
                  ),
                  if (_password2Ctrl.text.isNotEmpty &&
                      _passwordCtrl.text != _password2Ctrl.text) ...[
                    const SizedBox(height: 6),
                    const Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label:     '계좌 개설',
                isLoading: _isLoading,
                onPressed: _canSubmit ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) => InputDecoration(
  hintText:    hint,
  hintStyle:   const TextStyle(fontSize: 13, color: AppColors.gray400),
  counterText: '',
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:   const BorderSide(color: AppColors.gray200),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:   const BorderSide(color: AppColors.gray200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:   const BorderSide(color: AppColors.teal600),
  ),
);