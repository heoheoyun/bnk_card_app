import 'package:flutter/material.dart';
class BnkErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const BnkErrorView({super.key, required this.message, this.onRetry});
  @override Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center),
      if (onRetry != null) ...[const SizedBox(height: 16), ElevatedButton(onPressed: onRetry, child: const Text('다시 시도'))],
    ],
  ));
}
