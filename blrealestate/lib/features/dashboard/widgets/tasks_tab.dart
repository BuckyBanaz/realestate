import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/data_refresh_header.dart';
import 'shared_status_chip.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskProvider);
    
    return state.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(itemHeight: 120),
      ),
      error: (err, _) => RefreshIndicator(
        onRefresh: () async => ref.read(taskProvider.notifier).refresh(),
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
                  Text('Failed to load tasks', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 8),
                  Text('Pull down to retry', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(taskProvider.notifier).refresh(),
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
          onRefresh: () async => ref.read(taskProvider.notifier).refresh(),
          child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  DataRefreshHeader(
                    lastUpdated: metadata.formattedTime,
                    onRefresh: () async => ref.read(taskProvider.notifier).refresh(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      AppStrings.noTasks,
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
                      onRefresh: () async => ref.read(taskProvider.notifier).refresh(),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      i == 1 ? 10 : 0,
                      20,
                      i == items.length ? 40 : 0,
                    ),
                    child: _TaskTile(task: items[i - 1]),
                  );
                },
              ),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
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
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SharedStatusChip(
                    status: task.status,
                    color: AppColors.statusColor(task.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 4),
                  Text(
                    '${AppStrings.duePrefix}${DateFormatter.format(task.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                  ),
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
      builder: (_) => _TaskDetailSheet(task: task),
    );
  }
}

// ─── Task Detail Sheet ────────────────────────────────────────────────────────
class _TaskDetailSheet extends StatelessWidget {
  final TaskModel task;
  const _TaskDetailSheet({required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(task.status);

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
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(task.title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                SharedStatusChip(
                  status: task.status,
                  color: statusColor,
                ),
              ],
            ),
            const Divider(height: 24),
            // Details
            _row(context, Icons.description_outlined, 'Description', task.description),
            _row(context, Icons.calendar_today_outlined, 'Due Date', DateFormatter.format(task.dueDate)),
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
