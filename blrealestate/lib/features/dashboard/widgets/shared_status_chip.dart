import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class SharedStatusChip extends StatelessWidget {
  final String status;
  final String? currentStatus; // If null, acts as a purely display chip
  final bool isUpdating;
  final bool isSolid;
  final ValueChanged<String>? onUpdate;
  final Color color;

  const SharedStatusChip({
    super.key,
    required this.status,
    this.currentStatus,
    this.isUpdating = false,
    this.isSolid = false,
    this.onUpdate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // If currentStatus is null, it's just a display badge (not selectable)
    final isDisplayOnly = currentStatus == null;
    final isSelected = !isDisplayOnly && (currentStatus!.toLowerCase() == status.toLowerCase());
    
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: (isSelected || (isDisplayOnly && isSolid)) ? color : color.withValues(alpha: isDisplayOnly ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: (isSelected || (isDisplayOnly && isSolid)) ? 1 : 0.4),
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
            : [],
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: (isSelected || (isDisplayOnly && isSolid)) ? AppColors.surfaceLight : color, 
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (isDisplayOnly || onUpdate == null) {
      return content;
    }

    return GestureDetector(
      onTap: () {
        if (isSelected || isUpdating) return;
        HapticFeedback.mediumImpact();
        onUpdate!(status);
      },
      child: content,
    );
  }
}
