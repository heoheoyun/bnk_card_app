import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BnkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const BnkAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: showBack,
    actions: actions,
  );
}