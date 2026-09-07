import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/state_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../screens/inventory_detail_screen.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/safe_cache_manager.dart';
import 'shared_status_chip.dart';



class InventoryTab extends ConsumerStatefulWidget {
  const InventoryTab({super.key});

  @override
  ConsumerState<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<InventoryTab>
    with AutomaticKeepAliveClientMixin {
  ProviderSubscription<FilterCriteria?>? _filterSub;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterSub = ref.listenManual(categoryFilterProvider, (_, __) {
        if (mounted) {
          final notifier = ref.read(inventoryPageProvider.notifier);
          if (notifier.state != 1) notifier.state = 1;
          // Also clear search so stale query doesn't combine with new filter
          ref.read(inventorySearchProvider.notifier).state = '';
        }
      });
    });
  }

  @override
  void dispose() {
    _filterSub?.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(filteredInventoryProvider);
    final activeFilter = ref.watch(categoryFilterProvider);

    return state.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(itemHeight: 200),
      ),
      error: (err, _) => RefreshIndicator(
        onRefresh: () async => ref.read(inventoryProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary(context)),
                  const SizedBox(height: 12),
                  Text('Failed to load properties', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(inventoryProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      data: (data) {
        final (items, metadata) = data;
        final totalPages = metadata.totalPages;
        final currentPage = metadata.currentPage;

        // Filters applied purely on the client (API confirmed it ignores these params).
        // When any of these are active, pagination is locked to page 1 — navigating
        // to page 2 would fetch 20 unrelated server items and the client filter
        // would eliminate them all, showing 0 results.
        final hasClientOnlyFilter = activeFilter != null && (
          activeFilter.facing      != null ||
          activeFilter.minAreaSqYd != null ||
          activeFilter.isCorner    == true  ||
          activeFilter.subCategory != null
        );

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          // ignore: deprecated_member_use — scrollCacheExtent not available in this Flutter SDK version
          cacheExtent: 800,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false, // cards wrap themselves in RepaintBoundary
          itemCount: items.length +
              (totalPages > 1 ? 2 : 1) +
              (activeFilter != null && !activeFilter.isEmpty ? 1 : 0),
          itemBuilder: (context, i) {
            int offset = 0;

            if (activeFilter != null && !activeFilter.isEmpty) {
              if (i == 0) return _buildFilterSummary(activeFilter);
              offset = 1;
            }

            if (i == offset) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${metadata.totalItems ?? items.length} Properties',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    if (metadata.error != null)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.error_outline, size: 14, color: AppColors.pending),
                      ),
                  ],
                ),
              );
            }
            offset += 1;

            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(60),
                child: Text('No properties found matching your criteria',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)), textAlign: TextAlign.center),
              );
            }

            if (totalPages > 1 && i == items.length + offset) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  children: [
                    // Info banner when pagination is locked due to client-only filters
                    if (hasClientOnlyFilter)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pagination paused while facing / area / corner filter is active — these filter locally.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          // Disable Previous when loading, on page 1, OR when client-only filter locks pagination
                          onPressed: (state.isLoading || currentPage <= 1 || hasClientOnlyFilter) ? null : () => ref.read(inventoryProvider.notifier).previousPage(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                          label: Text('Previous', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        Text('Page $currentPage of $totalPages', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextButton.icon(
                            // Disable Next when loading, on last page, OR when client-only filter locks pagination
                            onPressed: (state.isLoading || currentPage >= totalPages || hasClientOnlyFilter) ? null : () => ref.read(inventoryProvider.notifier).nextPage(totalPages),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                            label: Text('Next', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            final cardIndex = i - offset;
            if (cardIndex < 0 || cardIndex >= items.length) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.fromLTRB(12, cardIndex == 0 ? 8 : 0, 12,
                  cardIndex == items.length - 1 ? 20 : 12),
              child: _InventoryCard(property: items[cardIndex]),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSummary(FilterCriteria f) {
    final text = [f.type, f.category, f.subCategory, f.location]
        .whereType<String>()
        .join(' > ');
    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () => ref.read(categoryFilterProvider.notifier).state = null,
            child: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryModel property;
  const _InventoryCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(property.displayStatus);
    final area = property.attributes['Plot Size']?.toString() ?? property.area;
    final location = [property.project, property.city]
        .where((v) => v != null && v.isNotEmpty)
        .join(', ');
    final category = property.category ?? property.propertyType ?? '';
    // Cache once — Theme.of(context) is O(n) tree walk, calling it 3× per card per frame adds up
    final grey = AppColors.textSecondary(context);
    final images = property.images;

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => InventoryDetailScreen(plot: property)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: images.isNotEmpty
                        // List cards: show only the first image statically.
                        // Full carousel on the detail screen where user actually swipes.
                        // Avoids creating PageController + ValueNotifier per card during fling.
                        ? CachedNetworkImage(
                            imageUrl: images.first,
                            cacheManager: SafeCacheManager(),
                            fit: BoxFit.cover,
                            memCacheWidth: 600,
                            memCacheHeight: 338, // 16:9 of 600px width
                            placeholder: (_, __) => ColoredBox(
                              color: statusColor.withValues(alpha: 0.1),
                              child: Center(child: Icon(Icons.apartment_rounded,
                                  size: 40, color: statusColor.withValues(alpha: 0.5))),
                            ),
                            errorWidget: (_, __, ___) => ColoredBox(
                              color: statusColor.withValues(alpha: 0.1),
                              child: Center(child: Icon(Icons.apartment_rounded,
                                  size: 40, color: statusColor.withValues(alpha: 0.5))),
                            ),
                          )
                        : ColoredBox(
                            color: statusColor.withValues(alpha: 0.1),
                            child: Center(child: Icon(Icons.apartment_rounded,
                                size: 40, color: statusColor.withValues(alpha: 0.5))),
                          ),
                  ),
                  if (category.isNotEmpty)
                    Positioned(
                      top: 8, left: 8,
                      child: SharedStatusChip(
                        status: category,
                        color: AppColors.primary,
                        isSolid: true,
                      ),
                    ),
                  Positioned(
                    top: 8, right: 8,
                    child: SharedStatusChip(
                      status: property.displayStatus,
                      color: statusColor,
                      isSolid: true,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 12, color: grey),
                        const SizedBox(width: 2),
                        Expanded(child: Text(location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                    const SizedBox(height: 6),
                    Text(PriceFormatter.formatWithRupee(property.price),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.bold)),
                    if (area.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.straighten_outlined, size: 12, color: grey),
                        const SizedBox(width: 2),
                        Text(area, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: grey)),
                      ]),
                    ],
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