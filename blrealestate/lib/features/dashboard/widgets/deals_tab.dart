import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/data_refresh_header.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../screens/deal_detail_screen.dart';

class DealsTab extends ConsumerWidget {
  const DealsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dealsProvider);
    
    return state.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(itemHeight: 140),
      ),
      error: (err, _) => RefreshIndicator(
        onRefresh: () async => ref.read(dealsProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary(context)),
                  SizedBox(height: 12),
                  Text('Failed to load deals', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  SizedBox(height: 8),
                  Text('Pull down to retry', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(dealsProvider.notifier).refresh(),
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
          onRefresh: () async => ref.read(dealsProvider.notifier).refresh(),
          child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  DataRefreshHeader(
                    lastUpdated: metadata.formattedTime,
                    onRefresh: () async => ref.read(dealsProvider.notifier).refresh(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      AppStrings.noDeals,
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
                      onRefresh: () async => ref.read(dealsProvider.notifier).refresh(),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      i == 1 ? 10 : 0,
                      20,
                      i == items.length ? 40 : 0,
                    ),
                    child: _DealCard(deal: items[i - 1]),
                  );
                },
              ),
        );
      },
    );
  }
}

class _DealCard extends StatelessWidget {
  final DealModel deal;

  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DealDetailScreen(deal: deal)),
      ),
      child: RepaintBoundary(
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                color: AppColors.textSecondary(context),
                child: (deal.bannerImage?.isNotEmpty ?? false)
                    ? CachedNetworkImage(
                        imageUrl: deal.bannerImage!,
                        cacheManager: SafeCacheManager(),
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        memCacheHeight: 200,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 48),
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      )
                    : const Icon(Icons.image_not_supported, size: 48),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.dealPrefix}${deal.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            deal.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
