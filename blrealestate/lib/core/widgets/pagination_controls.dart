import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back_ios_new, size: 14),
            label: const Text('Prev'),
            onPressed: currentPage <= 1 ? null : onPrevious,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            label: const Text('Next'),
            onPressed: currentPage >= totalPages ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
