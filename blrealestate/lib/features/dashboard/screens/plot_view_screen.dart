import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/filter_chip_widget.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/state_providers.dart';
import '../widgets/advanced_filter_sheet.dart';
import '../../../core/utils/filter_utils.dart';
import 'hold_property_screen.dart';



class PlotViewScreen extends ConsumerStatefulWidget {
  const PlotViewScreen({super.key});

  @override
  ConsumerState<PlotViewScreen> createState() => _PlotViewScreenState();
}

class _PlotViewScreenState extends ConsumerState<PlotViewScreen> {
  ProviderSubscription<FilterCriteria?>? _filterSub;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    // Reset page to 1 whenever the filter changes — same pattern as InventoryTab
    _filterSub = ref.listenManual(categoryFilterProvider, (_, __) {
      if (mounted) ref.read(inventoryPageProvider.notifier).state = 1;
    });
  }

  @override
  void dispose() {
    _filterSub?.close();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }


  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const AdvancedFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredInventoryProvider);
    
    // Extract pagination state from filteredAsync for bottomNavigationBar
    final metadata = filteredAsync.maybeWhen(
      data: (data) => data.$2,
      orElse: () => null,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.choosePlots,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.surfaceLight,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterStrip(),
          Expanded(
            child: filteredAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerGrid(),
              ),
              error: (_, __) => RefreshIndicator(
                onRefresh: () async => ref.read(inventoryProvider.notifier).refresh(),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary(context)),
                          const SizedBox(height: 12),
                          Text('Could not load inventory', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.read(inventoryProvider.notifier).refresh(),
                            child: const Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              data: (data) {
                final (allItems, _) = data;
                if (allItems.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => ref.read(inventoryProvider.notifier).refresh(),
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(AppStrings.noPlots, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)))
                          ),
                        )
                      ]
                    )
                  );
                }

                return Column(
                  children: [
                    _LegendRow(total: metadata?.totalItems ?? allItems.length),
                    if (filteredAsync.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(inventoryProvider.notifier).refresh();
                        },
                        color: AppColors.primary,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: allItems.length,
                          itemBuilder: (ctx, i) => _PlotTile(
                            plot: allItems[i],
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _showDetail(ctx, allItems[i]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),         // body Column
      bottomNavigationBar: (metadata != null && metadata.totalPages > 1)
          ? _PaginationBar(
              page: metadata.currentPage,
              totalPages: metadata.totalPages,
              onPrev: (metadata.currentPage > 1 && !filteredAsync.isLoading) ? () => ref.read(inventoryProvider.notifier).previousPage() : null,
              onNext: (metadata.currentPage < metadata.totalPages && !filteredAsync.isLoading) ? () => ref.read(inventoryProvider.notifier).nextPage(metadata.totalPages) : null,
            )
          : null,
    );
  }

  Widget _buildSearchAndFilterStrip() {
    final filter    = ref.watch(categoryFilterProvider);
    final dynData = ref.watch(dynamicFiltersProvider).valueOrNull ?? const <String, dynamic>{};
    final filteredAsync = ref.watch(filteredInventoryProvider);
    final count = filteredAsync.maybeWhen(data: (d) => d.$1.length, orElse: () => 0);
    final allPropertyTypes = FilterUtils.allPropertyTypes;
    final liveCategories = FilterUtils.getLiveCategories(filter?.type, dynData);
    final subCategories = FilterUtils.getSubCategories(filter?.type, filter?.category, dynData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              FilterChipWidget(icon: Icons.search_rounded, label: '', iconOnly: true, isActive: false, isPrimary: true, showArrow: false,
                  onTap: () => setState(() => _isSearchExpanded = !_isSearchExpanded)),
              const SizedBox(width: 8),
              FilterChipWidget(
                icon: Icons.home_work_outlined,
                label: filter?.type ?? 'Property Type',
                isActive: filter?.type != null,
                onTap: () => _showPicker('Property Type', allPropertyTypes, (v) =>
                    ref.read(categoryFilterProvider.notifier).state = FilterCriteria(type: v)),
              ),
              const SizedBox(width: 8),
              FilterChipWidget(
                icon: Icons.category_outlined,
                label: filter?.category ?? 'Category',
                isActive: filter?.category != null,
                enabled: filter?.type != null,
                onTap: () {
                  if (filter?.type == null) return;
                  _showPicker('Category', liveCategories, (v) =>
                      ref.read(categoryFilterProvider.notifier).state =
                          FilterCriteria(type: filter?.type, category: v));
                },
              ),
              const SizedBox(width: 8),
              FilterChipWidget(
                icon: Icons.layers_outlined,
                label: filter?.subCategory ?? 'Sub Category',
                isActive: filter?.subCategory != null,
                enabled: filter?.category != null,
                onTap: () {
                  if (filter?.category == null || subCategories.isEmpty) return;
                  _showPicker('Sub Category', subCategories, (v) =>
                      ref.read(categoryFilterProvider.notifier).state = FilterCriteria(
                          type: filter?.type, category: filter?.category, subCategory: v));
                },
              ),
              const SizedBox(width: 8),
              FilterChipWidget(icon: Icons.tune_rounded, label: '', iconOnly: true, showArrow: false,
                  isActive: filter?.isCorner != null || filter?.facing != null || filter?.minAreaSqYd != null,
                  onTap: _showFilterSheet),
            ],
          ),
        ),
        // Search bar (expandable)
        if (_isSearchExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.inputFill(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                onChanged: (v) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                    ref.read(inventorySearchProvider.notifier).state = v.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search plot #, title...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.primary,
                    onPressed: () {
                      setState(() => _isSearchExpanded = false);
                      _searchController.clear();
                      ref.read(inventorySearchProvider.notifier).state = '';
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        // Count bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count plots', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              if (filter != null && !filter.isEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref.read(categoryFilterProvider.notifier).state = null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.close, size: 11, color: AppColors.error),
                      SizedBox(width: 3),
                      Text('Clear', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showPicker(String title, List<String> items, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary(context), borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 12),
              Text('Select $title', style: Theme.of(context).textTheme.titleMedium),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(items[i]),
                    onTap: () { Navigator.pop(context); onSelected(items[i]); },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, InventoryModel plot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _PlotDetailSheet(plot: plot),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final int total;
  const _LegendRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _dot(context, AppColors.plotActive, AppStrings.available),
          const SizedBox(width: 14),
          _dot(context, AppColors.plotHold,   AppStrings.plotHoldLabel),
          const SizedBox(width: 14),
          _dot(context, AppColors.plotSold,   AppStrings.soldLabel),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total plots',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
    ],
  );
}

String _shortTitle(String title, String? project) {
  if (project != null && project.isNotEmpty) {
    if (title.endsWith(project)) {
      return title.substring(0, title.length - project.length).trim();
    }
  }
  return title;
}

class _PlotTile extends StatelessWidget {
  final InventoryModel plot;
  final VoidCallback onTap;

  const _PlotTile({required this.plot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = plot.displayStatus == 'HOLD' ? AppColors.plotHold : (plot.displayStatus == 'SOLD' ? AppColors.plotSold : AppColors.plotActive);
    final plotNo = _shortTitle(plot.title, plot.project);
    final plotSize = plot.attributes['Plot Size']?.toString() ?? plot.area;
    final priceText = PriceFormatter.formatWithRupee(plot.price);
    final statusLabel = plot.displayStatus == 'ACTIVE' ? AppStrings.available : (plot.displayStatus == 'HOLD' ? AppStrings.plotHoldLabel : AppStrings.soldLabel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 3, width: 28, margin: EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2))),
            Text(plotNo, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(plotSize, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (priceText.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(priceText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({required this.page, required this.totalPages, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.12))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Row(
            children: [
              // Previous button
              Expanded(
                child: _NavButton(
                  label: 'Previous',
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: onPrev,
                  iconAfter: false,
                ),
              ),
              // Page indicator pill
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '$page / $totalPages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              // Next button
              Expanded(
                child: _NavButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: onNext,
                  iconAfter: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool iconAfter;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.iconAfter,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final color = isEnabled ? AppColors.primary : AppColors.textSecondary(context).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.textSecondary(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconAfter
              ? [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isEnabled ? AppColors.surfaceLight : color, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Icon(icon, size: 13, color: isEnabled ? AppColors.surfaceLight : color),
                ]
              : [
                  Icon(icon, size: 13, color: isEnabled ? AppColors.surfaceLight : color),
                  const SizedBox(width: 6),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isEnabled ? AppColors.surfaceLight : color, fontWeight: FontWeight.w600)),
                ],
        ),
      ),
    );
  }
}

class _PlotDetailSheet extends ConsumerWidget {
  final InventoryModel plot;
  const _PlotDetailSheet({required this.plot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePlot = ref.watch(inventoryProvider).maybeWhen(
      data: (data) {
        final (items, _) = data;
        try { return items.firstWhere((i) => i.id == plot.id); } catch (_) { return plot; }
      },
      orElse: () => plot,
    );
    final statusColor = livePlot.displayStatus == 'HOLD' ? AppColors.plotHold : (livePlot.displayStatus == 'SOLD' ? AppColors.plotSold : AppColors.plotActive);
    final canHold = livePlot.displayStatus == 'ACTIVE';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.zero,
          children: [
            Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary(context), borderRadius: BorderRadius.circular(2)))),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.02)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withValues(alpha: 0.2))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(livePlot.title, style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 4),
                      Text(PriceFormatter.formatWithRupee(livePlot.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                      Text(livePlot.area, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                    ]),
                  ),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withValues(alpha: 0.3))), child: Text(livePlot.displayStatus, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            if (livePlot.attributes.isNotEmpty) ...[
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Property Attributes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.inputFill(context), borderRadius: BorderRadius.circular(16)),
                child: Column(children: _buildAttrRows(livePlot.attributes)),
              ),
            ],
            const SizedBox(height: 20),
            if (livePlot.latitude != null && livePlot.longitude != null) ...[
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Map View', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 180,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.2))),
                clipBehavior: Clip.antiAlias,
                // FIX #1: InteractiveFlag.none disables all map gestures (pan/zoom/fling).
                // Without this, flutter_map's gesture detector competed with
                // DraggableScrollableSheet + ListView during fling, causing ANR → crash.
                // The map is view-only here — user opens Google Maps for navigation.
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(livePlot.latitude!, livePlot.longitude!),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none, // no pan, no zoom, no fling
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.blrealestateapp.blrealestate',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(livePlot.latitude!, livePlot.longitude!),
                          child: const Icon(Icons.location_pin, color: AppColors.primary, size: 36),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final lat = livePlot.latitude;
                      final lng = livePlot.longitude;
                      if (lat == null || lng == null) return;
                      final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
                      final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                      if (await canLaunchUrl(geoUri)) {
                        await launchUrl(geoUri);
                      } else if (await canLaunchUrl(webUri)) {
                        await launchUrl(webUri, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {
                      // Maps not available on this device — silently ignore
                    }
                  },
                  icon: const Icon(Icons.map_outlined, size: 18), label: const Text('Open in Google Maps'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: canHold ? () {
                    // Removed commission-based authorization check.
                    // The backend will place the hold request in "pending" status for admin approval.
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HoldPropertyScreen(propertyId: livePlot.id, propertyTitle: livePlot.title)));
                  } : null,
                  icon: Icon(canHold ? Icons.lock_open_outlined : Icons.lock_outline),
                  label: Text(canHold ? AppStrings.holdUnit : 'Already ${livePlot.displayStatus}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: canHold ? AppColors.primary : AppColors.textSecondary(context), foregroundColor: canHold ? AppColors.surfaceLight : AppColors.textSecondary(context), elevation: canHold ? 4 : 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pre-builds attribute rows outside build() to avoid .map().toList() on every frame
List<Widget> _buildAttrRows(Map<String, dynamic> attrs) {
  final entries = attrs.entries
      .where((e) => e.value != null && e.value.toString().isNotEmpty)
      .toList();
  return [
    for (int i = 0; i < entries.length; i++)
      _AttrRow(
        label: entries[i].key,
        value: entries[i].value.toString(),
        isLast: i == entries.length - 1,
      ),
  ];
}

class _AttrRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _AttrRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.08)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context), fontWeight: FontWeight.w500)), Flexible(child: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold), textAlign: TextAlign.right))]),
    );
  }
}
