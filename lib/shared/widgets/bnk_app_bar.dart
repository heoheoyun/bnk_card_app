import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class BnkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final String? backPath;

  const BnkAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.backPath,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      onPressed: () {
        if (backPath != null) {
          context.go(backPath!);
        } else if (context.canPop()) {
          context.pop();
        } else {
          Navigator.of(context).maybePop();
        }
      },
    )
        : null,
    actions: actions,
  );
}