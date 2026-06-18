import 'package:flutter/material.dart';
class BnkEmptyView extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  const BnkEmptyView({super.key, required this.message, this.onAction, this.actionLabel});
  @override Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
      if (onAction != null && actionLabel != null) ...[
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ]),
  );
}
