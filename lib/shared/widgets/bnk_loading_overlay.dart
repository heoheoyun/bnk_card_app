import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
class BnkLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const BnkLoadingOverlay({super.key, required this.isLoading, required this.child});
  @override Widget build(BuildContext context) => Stack(children: [
    child,
    if (isLoading) const ColoredBox(color: Colors.black26,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
  ]);
}
