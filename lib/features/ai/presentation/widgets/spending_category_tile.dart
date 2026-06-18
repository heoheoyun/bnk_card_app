import 'package:flutter/material.dart';

class SpendingCategoryTile extends StatelessWidget {
  final String categoryName;
  final int    monthlyAmount;
  final void Function(int amount) onChanged;

  const SpendingCategoryTile({
    super.key,
    required this.categoryName,
    required this.monthlyAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(children: [
      Expanded(child: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.w500))),
      const SizedBox(width: 12),
      SizedBox(
        width: 120,
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: '원',
            hintText: '0',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          controller: TextEditingController(text: monthlyAmount == 0 ? '' : monthlyAmount.toString()),
          onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
        ),
      ),
    ]),
  );
}
