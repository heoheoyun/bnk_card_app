// 주소 변경 · CI(연계정보) 갱신 — 본인인증 화면.
//  - 이름 + 주민등록번호(앞 6자리 + 성별코드) + 새 주소(카카오 검색)를 입력해 인증하면
//    서버가 해당 주소로 CI값을 다시 생성해 저장한다.
//  - 주민번호 뒷자리(성별코드 제외)는 수집하지 않는다.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/address_search_field.dart';
import '../providers/mypage_provider.dart';

class AddressCiVerifyPage extends ConsumerStatefulWidget {
  const AddressCiVerifyPage({super.key});

  @override
  ConsumerState<AddressCiVerifyPage> createState() => _AddressCiVerifyPageState();
}

class _AddressCiVerifyPageState extends ConsumerState<AddressCiVerifyPage> {
  final _nameCtrl = TextEditingController();
  final _frontCtrl = TextEditingController(); // 주민번호 앞 6자리
  final _genderCtrl = TextEditingController(); // 성별코드 1자리
  final _postcodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController(); // 도로명(기본) 주소
  final _detailCtrl = TextEditingController(); // 상세 주소

  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _frontCtrl.dispose();
    _genderCtrl.dispose();
    _postcodeCtrl.dispose();
    _addressCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final front = _frontCtrl.text.trim();
    final gender = _genderCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    String? err;
    if (name.isEmpty) {
      err = '이름을 입력해 주세요.';
    } else if (front.length != 6 || int.tryParse(front) == null) {
      err = '주민등록번호 앞 6자리를 입력해 주세요.';
    } else if (!RegExp(r'^[1-4789]$').hasMatch(gender)) {
      err = '성별코드(뒷자리 첫 번째)를 입력해 주세요.';
    } else if (address.isEmpty) {
      err = '주소를 검색해 주세요.';
    }
    if (err != null) {
      _snack(err);
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(mypageDatasourceProvider).updateCi({
        'name': name,
        'residentFront': front,
        'genderCode': gender,
        'address': address,
        'addressDetail': _detailCtrl.text.trim(),
      });
      if (!mounted) return;
      _snack('주소가 변경되었습니다.');
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final code = e.response?.data is Map
          ? (e.response?.data as Map)['code']
          : null;
      _snack(code == 'CA003'
          ? '본인인증 정보가 계정과 일치하지 않습니다.'
          : '주소 변경에 실패했습니다. 잠시 후 다시 시도해 주세요.');
    } catch (_) {
      _snack('주소 변경에 실패했습니다. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '주소 변경 · 본인인증', backPath: '/mypage'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teal50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '주소를 변경하려면 본인인증이 필요합니다.\n'
                '입력 정보는 본인 확인 용도로만 사용되며 주민번호 뒷자리는 저장하지 않습니다.',
                style: TextStyle(fontSize: 12, color: AppColors.teal800, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            _label('이름'),
            TextField(controller: _nameCtrl, decoration: _dec('실명 입력')),
            const SizedBox(height: 16),

            _label('주민등록번호'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: TextField(
                    controller: _frontCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _dec('앞 6자리').copyWith(counterText: ''),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-', style: TextStyle(fontSize: 18)),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _genderCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _dec('●').copyWith(counterText: ''),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text('●●●●●●',
                      style: TextStyle(
                          color: AppColors.gray400, letterSpacing: 2)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AddressSearchField(
              postcodeController: _postcodeCtrl,
              addressController: _addressCtrl,
              detailController: _detailCtrl,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('본인인증 및 주소 변경',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
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
