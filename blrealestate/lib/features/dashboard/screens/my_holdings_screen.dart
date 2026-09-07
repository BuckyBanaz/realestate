import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'inventory_detail_screen.dart';

int? _parseInt(dynamic v) =>
    v is int ? v : int.tryParse(v?.toString() ?? '');

class MyHoldingsScreen extends ConsumerWidget {
  const MyHoldingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch allPropertiesDropdownProvider for the full list.
    // Merge with current-page inventoryProvider state so optimistic hold
    // (which lives in inventoryProvider) shows instantly without waiting
    // for a server round-trip.
    final allAsync = ref.watch(allPropertiesDropdownProvider);
    final currentPageItems = ref.watch(inventoryProvider).valueOrNull?.$1 ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Holdings',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
        elevation: 0,
      ),
      body: allAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(itemHeight: 100),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary(context)),
              const SizedBox(height: 12),
              Text('Could not load holdings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(allPropertiesDropdownProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allItems) {
          // Merge: overwrite server items with optimistic current-page state
          final currentMap = {for (final i in currentPageItems) i.id: i};
          final items = allItems.map((item) => currentMap[item.id] ?? item).toList();

          final profileData = ref.watch(profileProvider).valueOrNull ?? {};
          final myUserId = _parseInt(profileData['id']);

          // Filter properties held by THIS user only.
          // The /properties endpoint returns held_by (user id) and held_until (expiry).
          // active_hold object is NOT returned by the list endpoint — filter by held_by.
          final holdings = items.where((item) {
            if (myUserId == null) return false;
            // Check held_by matches current user
            if (item.heldBy == null || item.heldBy != myUserId) return false;
            // Check expiry if present
            final holdUntil = item.heldUntil ?? '';
            if (holdUntil.isNotEmpty) {
              try {
                final expiry = DateTime.parse(holdUntil);
                return expiry.isAfter(DateTime.now());
              } catch (_) {
                return true; // malformed date — show it anyway
              }
            }
            return true; // no expiry set — still held
          }).toList();

          if (holdings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_open_outlined, size: 72, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 16),
                  Text(
                    'No Holdings Yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Properties you hold will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allPropertiesDropdownProvider),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: holdings.length,
              itemBuilder: (context, i) => _HoldingCard(property: holdings[i]),
            ),
          );
        },
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final InventoryModel property;
  const _HoldingCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final area = property.attributes['Plot Size']?.toString() ?? property.area;
    final facing = property.attributes['Facing']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InventoryDetailScreen(plot: property)),
      ),
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.plotHold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.plotHold.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Square image
              SizedBox(
                width: 100,
                height: 100,
                child: property.image != null && property.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.image!,
                        cacheManager: SafeCacheManager(),
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        memCacheHeight: 200,
                        placeholder: (_, __) => Container(
                          color: AppColors.textSecondary(context),
                          child: Icon(Icons.apartment_rounded, color: AppColors.textSecondary(context)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.textSecondary(context),
                          child: Icon(Icons.apartment_rounded, color: AppColors.textSecondary(context), size: 32),
                        ),
                      )
                    : Container(
                        color: AppColors.textSecondary(context),
                        child: Icon(Icons.apartment_rounded, color: AppColors.textSecondary(context), size: 32),
                      ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + HOLD badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.plotHold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'HOLD',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.plotHold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (area.isNotEmpty)
                        Text(area, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                      if (facing.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('Facing: $facing', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            PriceFormatter.formatWithRupee(property.price),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'View Details',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
