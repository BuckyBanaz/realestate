import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FilterChipWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPrimary;
  final bool enabled;
  final bool iconOnly;
  final bool showArrow;

  const FilterChipWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isPrimary = false,
    this.enabled = true,
    this.iconOnly = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary
        ? AppColors.primary
        : isActive
            ? AppColors.primary
            : AppColors.inputFill(context);
    final fg = (isPrimary || isActive)
        ? AppColors.surfaceLight
        : AppColors.textSecondary(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? 12 : 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: enabled ? bg : AppColors.textSecondary(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary(context).withValues(alpha: 0.15),
          ),
        ),
        child: iconOnly
            ? Icon(icon, size: 17, color: enabled ? fg : AppColors.textSecondary(context))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: enabled ? fg : AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: enabled ? fg : AppColors.textSecondary(context),
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showArrow) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: enabled ? fg : AppColors.textSecondary(context),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
