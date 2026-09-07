import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notificationsTitle)),
      body: SafeArea(
        child: notificationsAsync.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(itemHeight: 120),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textSecondary(context)),
              const SizedBox(height: 12),
              Text(AppStrings.notifLoadFailed, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(notificationsProvider.notifier).refresh(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (data) {
          final (notifications, metadata) = data;
          return RefreshIndicator(
            onRefresh: () async => ref.read(notificationsProvider.notifier).refresh(),
            child: notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary(context)),
                            SizedBox(height: 12),
                            Text(AppStrings.noNotifications, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Last updated: ${DateFormatter.formatWithTime(metadata.lastUpdated.toIso8601String())}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                            ),
                          ),
                        );
                      }
                      
                      final item = notifications[index - 1];
                      return _NotificationCard(item: item, index: index - 1);
                    },
                  ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final int index;

  const _NotificationCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead
              ? AppColors.cardBorder(context)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _iconColor().withValues(alpha: 0.1),
            child: Icon(_iconData(), color: _iconColor(), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  DateFormatter.format(item.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconData() {
    switch (item.type.toLowerCase()) {
      case 'lead':
        return Icons.person_add_outlined;
      case 'task':
        return Icons.task_alt;
      case 'commission':
        return Icons.payments_outlined;
      case 'deal':
        return Icons.handshake_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColor() {
    switch (item.type.toLowerCase()) {
      case 'lead':
        return AppColors.notifLead;
      case 'task':
        return AppColors.notifTask;
      case 'commission':
        return AppColors.success;
      case 'deal':
        return AppColors.notifDeal;
      default:
        return AppColors.primary;
    }
  }
}
