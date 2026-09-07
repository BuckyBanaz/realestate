import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/filter_chip_widget.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../models/app_models.dart';
import '../../../core/utils/filter_utils.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/state_providers.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../widgets/advanced_filter_sheet.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/inventory_tab.dart';
import '../screens/plot_view_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Budget controllers must live on State — creating them inside _budgetRow()
  // (a build-time method) leaks a new controller on every rebuild and causes
  // text to reset mid-keystroke when onChanged triggers a provider update.
  final TextEditingController _minBudgetCtrl = TextEditingController();
  final TextEditingController _maxBudgetCtrl = TextEditingController();
  Timer? _searchDebounce;
  Timer? _minBudgetDebounce;
  Timer? _maxBudgetDebounce;
  bool _isSearchExpanded = false;
  bool _ready = false; // defer heavy build by one frame to avoid startup jank

  @override
  void initState() {
    super.initState();
    // Let the navigation animation complete before building the full tree.
    // This eliminates the "Skipped 83 frames" at startup.
    // Two-frame delay: first frame builds the skeleton, second frame triggers
    // the heavy providers — prevents simultaneous GPU frame + network burst
    // that causes BLASTBufferQueue overflow (max frames exceeded crash).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    _searchDebounce?.cancel();
    _minBudgetDebounce?.cancel();
    _maxBudgetDebounce?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    try {
      await Future.wait([
        ref.read(statsProvider.notifier).refresh(),
        ref.read(inventoryProvider.notifier).refresh(),
      ]);
      await Future.wait([
        ref.read(leadProvider.notifier).refresh(),
        ref.read(taskProvider.notifier).refresh(),
      ]);
      await Future.wait([
        ref.read(dealsProvider.notifier).refresh(),
        ref.read(commissionProvider.notifier).refresh(),
        ref.read(notificationsProvider.notifier).refresh(),
      ]);
    } catch (e, stack) {
      debugPrint('Error during dashboard refresh: $e\n$stack');
      // If mounted, you could show a snackbar here, but silent fail is fine
      // since the providers themselves handle setting error states.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers strictly inside the build method
    final filter = ref.watch(categoryFilterProvider);
    final dynData = ref.watch(dynamicFiltersProvider).valueOrNull ?? const <String, dynamic>{};

    // First frame: return lightweight placeholder so navigation animation is smooth.
    // _ready flips to true on the next frame via addPostFrameCallback.
    if (!_ready) {
      return Scaffold(
        body: Column(children: [_buildAppBarFixed()]),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Fixed app bar — never scrolls
          _buildAppBarFixed(),
          Expanded(
            child: NestedScrollView(
              // floatHeaderSlivers disabled — was causing extra layout passes
              // per scroll frame during fast fling on MediaTek devices, which
              // combined with ListView card builds was triggering ANR (signal 3).
              // Header now pins at top like a normal SliverAppBar.
              floatHeaderSlivers: false,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: _buildFilterChipsStrip(filter, dynData),
                    ),
                  ),
                ];
              },
              body: Builder(
                builder: (context) => RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  // InventoryTab's ListView IS the inner scroll view.
                  // NestedScrollView coordinates its scrolling with the
                  // outer header collapse directly.
                  child: const InventoryTab(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarFixed() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.dashboardTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                ),
                const DashboardHeader(),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
            icon: const Icon(Icons.search_rounded, color: AppColors.surfaceLight, size: 28),
          ),
              Consumer(
                builder: (context, ref, _) {
                  final notifAsync = ref.watch(notificationsProvider);
                  final unreadCount = notifAsync.maybeWhen(
                    data: (data) => data.$1.where((n) => !n.isRead).length,
                    orElse: () => 0,
                  );
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.surfaceLight, size: 28),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildFilterChipsStrip(FilterCriteria? filter, Map<String, dynamic> dynData) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1100;
    final isTablet  = w >= 600 && w < 1100;

    final allPropertyTypes = FilterUtils.allPropertyTypes;
    final liveCategories   = FilterUtils.getLiveCategories(filter?.type, dynData);
    final subCategories    = FilterUtils.getSubCategories(filter?.type, filter?.category, dynData);

    // ── chip builders ────────────────────────────────────────────────────────
    final typeChip = FilterChipWidget(
      icon: Icons.home_work_outlined,
      label: filter?.type ?? 'Property Type',
      isActive: filter?.type != null,
      onTap: () => _showPicker('Property Type', allPropertyTypes, (v) {
        ref.read(categoryFilterProvider.notifier).state = FilterCriteria(type: v);
      }),
    );
    final categoryChip = FilterChipWidget(
      icon: Icons.category_outlined,
      label: filter?.category ?? 'Category',
      isActive: filter?.category != null,
      enabled: filter?.type != null,
      onTap: () {
        if (filter?.type == null) { AppSnackBar.error(context, 'Select Property Type first'); return; }
        _showPicker('Category', liveCategories, (v) {
          ref.read(categoryFilterProvider.notifier).state = FilterCriteria(type: filter?.type, category: v);
        });
      },
    );
    final subCategoryChip = FilterChipWidget(
      icon: Icons.layers_outlined,
      label: filter?.subCategory ?? 'Sub Category',
      isActive: filter?.subCategory != null,
      enabled: filter?.category != null,
      onTap: () {
        if (filter?.category == null) { AppSnackBar.error(context, 'Select Category first'); return; }
        if (subCategories.isEmpty) { AppSnackBar.error(context, 'No sub-categories available'); return; }
        _showPicker('Sub Category', subCategories, (v) {
          ref.read(categoryFilterProvider.notifier).state = FilterCriteria(
            type: filter?.type, category: filter?.category, subCategory: v,
          );
        });
      },
    );
    final plotViewChip = FilterChipWidget(
      icon: Icons.grid_view_rounded,
      label: 'Plot View',
      isActive: false,
      isPrimary: true,
      showArrow: false,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlotViewScreen())),
    );
    final filtersChip = FilterChipWidget(
      icon: Icons.tune_rounded,
      label: 'Filters',
      isActive: filter?.isCorner != null || filter?.facing != null || filter?.minAreaSqYd != null,
      showArrow: false,
      onTap: () => _showFilterSheet(context),
    );

    final budgetRow = _budgetRow(filter);

    // ── responsive layout ────────────────────────────────────────────────────
    Widget chipsLayout;
    if (isDesktop) {
      chipsLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: typeChip),
              const SizedBox(width: 8),
              Expanded(child: categoryChip),
              const SizedBox(width: 8),
              Expanded(child: subCategoryChip),
              const SizedBox(width: 8),
              Expanded(child: plotViewChip),
              const SizedBox(width: 8),
              Expanded(child: filtersChip),
            ],
          ),
          const SizedBox(height: 8),
          budgetRow,
        ],
      );
    } else if (isTablet) {
      chipsLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: typeChip),
              const SizedBox(width: 8),
              Expanded(child: categoryChip),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: subCategoryChip),
              const SizedBox(width: 8),
              Expanded(child: plotViewChip),
              const SizedBox(width: 8),
              Expanded(child: filtersChip),
            ],
          ),
          const SizedBox(height: 8),
          budgetRow,
        ],
      );
    } else {
      chipsLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          typeChip,
          const SizedBox(height: 8),
          categoryChip,
          const SizedBox(height: 8),
          subCategoryChip,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: plotViewChip),
              const SizedBox(width: 8),
              Expanded(child: filtersChip),
            ],
          ),
          const SizedBox(height: 8),
          budgetRow,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          chipsLayout,
          // Search bar — slides in below chips when search icon tapped
          if (_isSearchExpanded) ...[  
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.inputFill(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                onChanged: (v) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                    ref.read(inventorySearchProvider.notifier).state = v.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search properties...',
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
          ],
          // Clear all filters
          if (filter != null && !filter.isEmpty) ...[  
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => ref.read(categoryFilterProvider.notifier).state = null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 11, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Clear all filters',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _budgetRow(FilterCriteria? filter) {
    // Sync controller text only when filter changes externally (e.g. clear button),
    // but don't overwrite if the user is actively typing (controller already has focus).
    final minText = filter?.minPrice != null ? filter!.minPrice!.toInt().toString() : '';
    final maxText = filter?.maxPrice != null ? filter!.maxPrice!.toInt().toString() : '';
    // Only sync when not composing AND text actually differs (external change like clear).
    // Use full value assignment with cursor at end to avoid cursor jumping to position 0.
    if (!_minBudgetCtrl.value.composing.isValid && _minBudgetCtrl.text != minText) {
      _minBudgetCtrl.value = TextEditingValue(
        text: minText,
        selection: TextSelection.collapsed(offset: minText.length),
      );
    }
    if (!_maxBudgetCtrl.value.composing.isValid && _maxBudgetCtrl.text != maxText) {
      _maxBudgetCtrl.value = TextEditingValue(
        text: maxText,
        selection: TextSelection.collapsed(offset: maxText.length),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minBudgetCtrl,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            onChanged: (v) {
              _minBudgetDebounce?.cancel();
              _minBudgetDebounce = Timer(const Duration(milliseconds: 400), () {
                final min = double.tryParse(v.trim());
                final current = ref.read(categoryFilterProvider);
                ref.read(categoryFilterProvider.notifier).state = (current ?? FilterCriteria()).copyWith(
                  minPrice: min,
                  clearMinPrice: min == null,
                );
              });
            },
            decoration: InputDecoration(
              hintText: 'Min Budget',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
              prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              filled: true,
              fillColor: AppColors.inputFill(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('—', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
        ),
        Expanded(
          child: TextField(
            controller: _maxBudgetCtrl,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyMedium,
            onChanged: (v) {
              _maxBudgetDebounce?.cancel();
              _maxBudgetDebounce = Timer(const Duration(milliseconds: 400), () {
                final max = double.tryParse(v.trim());
                final current = ref.read(categoryFilterProvider);
                ref.read(categoryFilterProvider.notifier).state = (current ?? FilterCriteria()).copyWith(
                  maxPrice: max,
                  clearMaxPrice: max == null,
                );
              });
            },
            decoration: InputDecoration(
              hintText: 'Max Budget',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
              prefixIcon: const Icon(Icons.currency_rupee, size: 16, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              filled: true,
              fillColor: AppColors.inputFill(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.textSecondary(context).withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }



  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AdvancedFilterSheet(),
    );
  }

  void _showPicker(
    String title,
    List<String> items,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select $title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(items[i]),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(items[i]);
                    },
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
