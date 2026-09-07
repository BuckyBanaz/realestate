import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/price_formatter.dart';

class DashboardStatsOverlay extends ConsumerWidget {
  final bool compact;
  const DashboardStatsOverlay({super.key, this.compact = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState      = ref.watch(statsProvider);
    final totalEarnings   = ref.watch(totalEarningsProvider);
    final earnings        = PriceFormatter.formatFull(totalEarnings);

    return statsState.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (stats) {
        final active = stats['active_leads']?.toString() ?? '0';
        final total  = stats['total_deals']?.toString() ?? '0';
        final totalInventory = stats['total_inventory']?.toString() ?? '0';

        if (compact) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _compactItem(context, active, AppStrings.activeLeads, Icons.flash_on_rounded, AppColors.statBlue[1]),
              _compactItem(context, total, AppStrings.totalDeals, Icons.auto_awesome_rounded, AppColors.statOrange[1]),
              _compactItem(context, totalInventory, 'Inventory', Icons.apartment_rounded, AppColors.statGreen[1]),
              _compactItem(context, '₹$earnings', AppStrings.earnings, Icons.account_balance_wallet_rounded, AppColors.statPurple[1]),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _largeItem(context, active, AppStrings.activeLeads, Icons.flash_on_rounded, AppColors.statBlue[1]),
            _largeItem(context, total, AppStrings.totalDeals, Icons.auto_awesome_rounded, AppColors.statOrange[1]),
            _largeItem(context, totalInventory, 'Inventory', Icons.apartment_rounded, AppColors.statGreen[1]),
            _largeItem(context, '₹$earnings', AppStrings.earnings, Icons.account_balance_wallet_rounded, AppColors.statPurple[1]),
          ],
        );
      },
    );
  }

  Widget _compactItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _largeItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
