import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DataRefreshHeader extends StatelessWidget {
  final String lastUpdated;
  final VoidCallback onRefresh;
  final bool isLoading;

  const DataRefreshHeader({
    super.key,
    required this.lastUpdated,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Last updated: $lastUpdated',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
          ),
          GestureDetector(
            onTap: isLoading ? null : onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

