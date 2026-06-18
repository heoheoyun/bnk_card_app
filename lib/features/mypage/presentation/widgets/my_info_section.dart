import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/mask_util.dart';

class MyInfoSection extends StatelessWidget {
  final Map<String, dynamic> info;
  const MyInfoSection({super.key, required this.info});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _InfoRow(label: '이름',   value: info['name']  as String? ?? ''),
      _InfoRow(label: '이메일', value: MaskUtil.email(info['email'] as String? ?? '')),
      _InfoRow(label: '전화번호', value: MaskUtil.phone(info['phone'] as String? ?? '')),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]),
  );
}
