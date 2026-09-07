import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SharedErrorView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final double iconSize;

  const SharedErrorView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.wifi_off_rounded,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppColors.textSecondary(context)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
            ],
          ],
        ),
      ),
    );
  }
}
