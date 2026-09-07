import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/state_providers.dart';
import '../../../providers/categories_provider.dart';
import '../../../models/app_models.dart';

class AdvancedFilterSheet extends ConsumerStatefulWidget {
  const AdvancedFilterSheet({super.key});

  @override
  ConsumerState<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends ConsumerState<AdvancedFilterSheet> {
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedLocation;
  bool? _isCorner;
  String? _facing;
  double? _minAreaSqYd;

  final TextEditingController _customLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = ref.read(categoryFilterProvider);
    if (f != null) {
      _selectedType        = f.type;
      _selectedCategory    = f.category;
      _selectedSubCategory = f.subCategory;
      _selectedLocation    = f.location;
      _isCorner            = f.isCorner;
      _facing              = f.facing;
      _minAreaSqYd         = f.minAreaSqYd;
    }
  }

  @override
  void dispose() {
    _customLocationController.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(categoryFilterProvider.notifier).state = FilterCriteria(
      type:        _selectedType,
      category:    _selectedCategory,
      subCategory: _selectedSubCategory,
      location:    _selectedLocation,
      isCorner:    _isCorner,
      facing:      _facing,
      minAreaSqYd: _minAreaSqYd,
      // preserve existing price values set from home screen budget row
      minPrice:    ref.read(categoryFilterProvider)?.minPrice,
      maxPrice:    ref.read(categoryFilterProvider)?.maxPrice,
    );
    Navigator.pop(context);
  }

  void _clear() {
    setState(() {
      _selectedType = _selectedCategory = _selectedSubCategory = _selectedLocation = null;
      _isCorner = null;
      _facing = null;
      _minAreaSqYd = null;
    });
    _customLocationController.clear();
    ref.read(categoryFilterProvider.notifier).state = null;
  }

  // ── Build merged hierarchy: fixed skeleton + live backend data ──────────────
  Map<String, Map<String, List<String>>> _buildHierarchy(List<CategoryNode> backendNodes, Map<String, dynamic> dynData) {
    // Fixed skeleton — always shown (client requirement)
    final Map<String, Map<String, List<String>>> h = {
      'Plots': {
        'Residential': ['General Plot', 'Township Plot', 'Corner Plot', 'Park Facing Plot', 'Road Facing Plot'],
        'Commercial':  ['Retail', 'Office'],
        'Industrial':  [],
        'Custom':      [],
      },
      'Farmhouses': {
        'Build-in': [],
        'Plots':    [],
        'Custom':   [],
      },
      'Flats-Housing': {
        'House':   [],
        'Flats':   [],
        'Custom':  [],
      },
      'Agricultural Land': {
        'Agricultural land': [],
        'Custom':            [],
      },
      'Township': {
        'Residential': [],
        'Integrated':  [],
        'Gated':       [],
        'Custom':      [],
      },
      'Society': {
        'Apartment Society':   [],
        'Under Construction':  [],
        'Custom':              [],
      },
    };

    // Deep-copy so we don't mutate the const
    final merged = h.map((type, cats) => MapEntry(
      type,
      cats.map((cat, subs) => MapEntry(cat, List<String>.from(subs))),
    ));

    // Merge live backend /categories API data on top
    for (final node in backendNodes) {
      final typeName = node.name;
      merged.putIfAbsent(typeName, () => {});
      for (final cat in node.children) {
        merged[typeName]!.putIfAbsent(cat.name, () => []);
        for (final sub in cat.children) {
          if (!merged[typeName]![cat.name]!.contains(sub.name)) {
            merged[typeName]![cat.name]!.add(sub.name);
          }
        }
      }
    }

    // Also merge live inventory subcategory data (most reliable source)
    for (final type in merged.keys) {
      final liveTypeMap = dynData[type];
      if (liveTypeMap is Map) {
        for (final cat in liveTypeMap.keys.cast<String>()) {
          if (cat == 'Other') continue;
          merged[type]!.putIfAbsent(cat, () => []);
          final liveSubs = List<String>.from(liveTypeMap[cat] ?? []);
          for (final sub in liveSubs) {
            if (!merged[type]![cat]!.contains(sub)) {
              merged[type]![cat]!.add(sub);
            }
          }
        }
      }
    }

    return merged;
  }

  Map<String, Map<String, List<String>>>? _cachedHierarchy;
  List<CategoryNode>? _lastBackendNodes;
  Map<String, dynamic>? _lastDynData;

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);
    final cities    = ref.watch(locationListProvider);
    final dynData   = ref.watch(dynamicFiltersProvider).valueOrNull ?? const <String, dynamic>{};

    final backendNodes = catsAsync.valueOrNull ?? [];
    if (_cachedHierarchy == null || _lastBackendNodes != backendNodes || _lastDynData != dynData) {
      _lastBackendNodes = backendNodes;
      _lastDynData = dynData;
      _cachedHierarchy = _buildHierarchy(backendNodes, dynData);
    }
    final merged = _cachedHierarchy!;

    // Fixed order for the 6 types
    const typeOrder = ['Plots', 'Farmhouses', 'Flats-Housing', 'Agricultural Land', 'Township', 'Society'];
    // Any extra types from backend that aren't in fixed list
    final extraTypes = merged.keys.where((t) => !typeOrder.contains(t)).toList()..sort();
    final allTypes = [...typeOrder, ...extraTypes];

    final hasFilter = _selectedType != null || _selectedLocation != null ||
        _isCorner != null || _facing != null || _minAreaSqYd != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textSecondary(context), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (hasFilter)
                    TextButton(
                      onPressed: _clear,
                      child: Text('Clear All', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [

                  // ── Property Type → Category → Sub Category (full tree always visible) ──
                  _sectionHeader('Property Type'),
                  ...allTypes.map((type) {
                    final cats = merged[type] ?? {};
                    final isTypeSelected = _selectedType == type;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type row
                        _typeRow(type, isTypeSelected, () {
                          setState(() {
                            if (isTypeSelected) {
                              _selectedType = null;
                              _selectedCategory = null;
                              _selectedSubCategory = null;
                            } else {
                              _selectedType = type;
                              _selectedCategory = null;
                              _selectedSubCategory = null;
                            }
                          });
                        }),

                        // Categories — always visible under each type
                        if (cats.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 6, bottom: 4),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: cats.keys.map((cat) {
                                final isCatSelected = isTypeSelected && _selectedCategory == cat;
                                final subs = cats[cat] ?? [];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _smallChip(
                                      label: cat,
                                      selected: isCatSelected,
                                      onTap: () => setState(() {
                                        if (!isTypeSelected) {
                                          _selectedType = type;
                                        }
                                        if (isCatSelected) {
                                          _selectedCategory = null;
                                          _selectedSubCategory = null;
                                        } else {
                                          _selectedCategory = cat;
                                          _selectedSubCategory = null;
                                        }
                                      }),
                                    ),
                                    // Sub-categories — shown inline when category selected
                                    if (isCatSelected && subs.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, top: 4),
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: subs.map((sub) => _tinyChip(
                                            label: sub,
                                            selected: _selectedSubCategory == sub,
                                            onTap: () => setState(() =>
                                              _selectedSubCategory = _selectedSubCategory == sub ? null : sub,
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 4),
                      ],
                    );
                  }),

                  const Divider(height: 32),

                  // ── Direction & Corner ──────────────────────────────────
                  _sectionHeader('Direction & Details'),
                  _label('Facing (8 Directions)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['North', 'North-East', 'East', 'South-East', 'South', 'South-West', 'West', 'North-West']
                        .map((dir) {
                      final sel = _facing == dir;
                      return ChoiceChip(
                        label: Text(dir, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sel ? AppColors.surfaceLight : AppColors.textPrimary(context))),
                        selected: sel,
                        onSelected: (v) => setState(() => _facing = v ? dir : null),
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  _label('Corner Plot'),
                  _smallChip(
                    label: 'Corner Plot Only',
                    selected: _isCorner == true,
                    onTap: () => setState(() => _isCorner = _isCorner == true ? null : true),
                  ),

                  const Divider(height: 32),

                  // ── Minimum Area ────────────────────────────────────────
                  _sectionHeader('Minimum Area'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [100.0, 200.0, 300.0, 400.0, 500.0].map((area) {
                      final sel = _minAreaSqYd == area;
                      return ChoiceChip(
                        label: Text('Above ${area.toInt()} sqyd',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sel ? AppColors.surfaceLight : AppColors.textPrimary(context))),
                        selected: sel,
                        onSelected: (v) => setState(() => _minAreaSqYd = v ? area : null),
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),

                  const Divider(height: 32),

                  // ── Location ────────────────────────────────────────────
                  _sectionHeader('Location'),
                  if (cities.isNotEmpty)
                    _dropdown(
                      value: cities.contains(_selectedLocation) ? _selectedLocation : null,
                      hint: 'Select City',
                      items: cities,
                      onChanged: (v) => setState(() => _selectedLocation = v),
                    ),
                  const SizedBox(height: 10),
                  _label('Or enter custom location'),
                  TextField(
                    controller: _customLocationController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Juglan, Dhingtana...',
                      prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onChanged: (v) => setState(() => _selectedLocation = v.trim().isEmpty ? null : v.trim()),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Apply button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: AppColors.textPrimary(context).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: PremiumButton(text: 'Apply Filters', onPressed: _apply),
            ),
          ],
        ),
      ),
    );
  }

  // ── Type row — bold label, tap to select ──────────────────────────────────
  Widget _typeRow(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.inputFill(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textSecondary(context).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 15,
                color: selected ? AppColors.surfaceLight : AppColors.textSecondary(context)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: selected ? AppColors.surfaceLight : AppColors.textSecondary(context), fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Icon(
              selected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: selected ? AppColors.surfaceLight : AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.inputFill(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.textSecondary(context).withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: selected ? AppColors.surfaceLight : AppColors.textSecondary(context)),
        ),
      ),
    );
  }

  Widget _tinyChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textSecondary(context).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary(context)),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context), fontWeight: FontWeight.w600)),
  );

  Widget _dropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(hint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}
