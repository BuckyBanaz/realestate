import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../models/app_models.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/data_refresh_header.dart';

class EarningsTab extends ConsumerWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commissionProvider);
    
    return state.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(itemHeight: 120),
      ),
      error: (err, _) => RefreshIndicator(
        onRefresh: () async => ref.read(commissionProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 12),
                  Text('Failed to load earnings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 8),
                  Text('Pull down to retry', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(commissionProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      data: (data) {
        final (items, metadata) = data;
        
        return RefreshIndicator(
          onRefresh: () async => ref.read(commissionProvider.notifier).refresh(),
          child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  DataRefreshHeader(
                    lastUpdated: metadata.formattedTime,
                    onRefresh: () async => ref.read(commissionProvider.notifier).refresh(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      AppStrings.noEarnings,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return DataRefreshHeader(
                      lastUpdated: metadata.formattedTime,
                      onRefresh: () async => ref.read(commissionProvider.notifier).refresh(),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      i == 1 ? 10 : 0,
                      20,
                      i == items.length ? 40 : 0,
                    ),
                    child: _CommissionTile(commission: items[i - 1]),
                  );
                },
              ),
        );
      },
    );
  }
}

class _CommissionTile extends StatelessWidget {
  final CommissionModel commission;
  const _CommissionTile({required this.commission});

  @override
  Widget build(BuildContext context) {
    final isCredited = commission.status.toLowerCase() == 'paid' || commission.status.toLowerCase() == 'credited';
    final statusColor = isCredited ? AppColors.success : AppColors.pending;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      commission.propertyTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      commission.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${PriceFormatter.format(commission.amount)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 4),
                  Text(commission.date.isNotEmpty ? DateFormatter.format(commission.date) : 'N/A',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _CommissionDetailSheet(commission: commission),
    );
  }
}

// ─── Commission Detail Sheet ──────────────────────────────────────────────────
class _CommissionDetailSheet extends StatelessWidget {
  final CommissionModel commission;
  const _CommissionDetailSheet({required this.commission});

  @override
  Widget build(BuildContext context) {
    final isCredited = commission.status.toLowerCase() == 'paid' || commission.status.toLowerCase() == 'credited';
    final statusColor = isCredited ? AppColors.success : AppColors.pending;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textSecondary(context), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.04)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(commission.propertyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(
                          '₹${PriceFormatter.format(commission.amount)}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      commission.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Details — all fields backend sends
            _row(context, Icons.apartment_rounded, 'Property',
                commission.propertyTitle),
            _row(context, Icons.currency_rupee_rounded, 'Amount',
                '₹${PriceFormatter.format(commission.amount)}'),
            _row(context, Icons.category_outlined, 'Commission Type',
                commission.commissionType.isNotEmpty
                    ? commission.commissionType[0].toUpperCase() + commission.commissionType.substring(1)
                    : 'N/A'),
            _row(context, Icons.notes_outlined, 'Remarks',
                commission.remarks.isNotEmpty ? commission.remarks : 'N/A'),
            _row(context, Icons.calendar_today_outlined, 'Date',
                DateFormatter.format(commission.date)),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
