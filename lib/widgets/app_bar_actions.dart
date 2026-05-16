import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'notifications_panel.dart';

class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          icon: Icons.star_rounded,
          color: AppColors.accent,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _CircleButton(
          icon: Icons.notifications_rounded,
          color: AppColors.secondary,
          onTap: () => _showNotifications(context),
        ),
        const SizedBox(width: 4),
        Container(
          width: 1,
          height: 28,
          color: AppColors.divider,
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),
        _CircleButton(
          icon: Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
          onTap: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsPanel(),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.iconBg,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
