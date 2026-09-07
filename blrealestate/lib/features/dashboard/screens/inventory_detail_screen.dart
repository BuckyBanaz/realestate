import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/app_models.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/api_provider.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import 'full_screen.dart';
import 'hold_property_screen.dart';
import '../../../core/widgets/property_image_carousel.dart';
import '../widgets/shared_status_chip.dart';

class InventoryDetailScreen extends ConsumerStatefulWidget {
  final InventoryModel plot;
  const InventoryDetailScreen({super.key, required this.plot});

  @override
  ConsumerState<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  List<String> _galleryImages = [];
  bool _hasGalleryError = false;

  @override
  void initState() {
    super.initState();
    // Defer fetch to after first frame — route must finish building before network call
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchImages());
  }

  Future<void> _fetchImages() async {
    if (!mounted) return;
    try {
      final res = await ref.read(apiClientProvider).get(
        ApiEndpoints.propertyDetail(widget.plot.id),
      );
      // Guard after await — widget may have been disposed during the network call
      if (!mounted) return;
      final data = res.data['data'] ?? res.data;
      if (data is! Map<String, dynamic>) return;

      final List<String> combined = [];

      // 1. Always add main_image first
      final mainImage = widget.plot.image ?? '';
      if (mainImage.isNotEmpty) combined.add(mainImage);

      // 2. Append gallery images, skip duplicates by filename
      final rawImages = data['images'];
      if (rawImages is List) {
        for (final img in rawImages) {
          final rawSrc = img is Map
              ? (img['image'] ?? img['url'] ?? img['image_url'])?.toString()
              : img?.toString();
          if (rawSrc == null || rawSrc.isEmpty) continue;
          // Normalize relative paths to full URL
          final src = (rawSrc.startsWith('http://') || rawSrc.startsWith('https://'))
              ? rawSrc
              : '${AppConfig.propertyImageBase}$rawSrc';
          final filename = src.split('/').last.split('?').first;
          final isDuplicate = combined.any(
              (u) => u.split('/').last.split('?').first == filename);
          if (!isDuplicate) combined.add(src);
        }
      }

      if (combined.isNotEmpty && mounted) {
        setState(() {
          _galleryImages = combined;
          _hasGalleryError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasGalleryError = true);
      }
    }
  }
  void _openImageZoom(BuildContext context, String imageUrl, String heroTag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FullScreenImageViewer(
        imageUrl: imageUrl,
        heroTag: heroTag,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Watch live inventory so status updates immediately after hold
    final livePlot = ref.watch(inventoryProvider).maybeWhen(
      data: (data) {
        final (items, _) = data;
        try {
          return items.firstWhere((i) => i.id == widget.plot.id);
        } catch (_) {
          return widget.plot;
        }
      },
      orElse: () => widget.plot,
    );
    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width * (9 / 16),
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                livePlot.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PropertyImageCarousel(
                    images: _galleryImages.isNotEmpty
                        ? _galleryImages
                        : (livePlot.image != null ? [livePlot.image!] : []),
                    plotId: livePlot.id,
                    onTap: (url, tag) => _openImageZoom(context, url, tag),
                    dotBottomOffset: 56,
                  ),
                  if (_hasGalleryError)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: SafeArea(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _hasGalleryError = false);
                            _fetchImages();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price + Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.investmentAmount, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
                          Text(
                            PriceFormatter.formatWithRupee(livePlot.price),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Flexible(
                        child: SharedStatusChip(
                          status: livePlot.displayStatus,
                          color: AppColors.statusColor(livePlot.displayStatus),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description — always shown
                  Text('About', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    livePlot.description != null && livePlot.description!.isNotEmpty
                        ? _stripHtml(livePlot.description!)
                        : 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 32),

                  // Dynamic Attributes Grid
                  Text(AppStrings.propertyDetails, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDetailGrid(context, livePlot),
                  
                  const SizedBox(height: 32),
                  
                  // Amenities
                  if (livePlot.amenities.isNotEmpty) ...[
                    Text(AppStrings.amenities, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final a in livePlot.amenities) _buildAmenityChip(a),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Hold Unit button — disabled when already on hold
                  if (livePlot.displayStatus == 'ACTIVE' || livePlot.displayStatus == 'HOLD')
                    PremiumButton(
                      text: livePlot.displayStatus == 'HOLD' ? 'Already on Hold' : AppStrings.holdUnit,
                      onPressed: livePlot.displayStatus == 'HOLD'
                          ? null
                          : () => _onHoldTap(context, livePlot),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check commission authorization via remarks percentage
  void _onHoldTap(BuildContext context, InventoryModel plot) {
    // Removed commission-based authorization check.
    // The backend will place the hold request in "pending" status for admin approval.

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HoldPropertyScreen(
          propertyId: plot.id,
          propertyTitle: plot.title,
        ),
      ),
    );
  }

  Widget _buildAmenityChip(dynamic amenity) {
    final title = amenity is Map ? (amenity['title'] ?? 'Feature') : amenity.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textSecondary(context).withValues(alpha: 0.05),
        border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, InventoryModel plot) {
    final attrs = plot.attributes;
    if (attrs.isEmpty) {
      return Text(AppStrings.noDetailsAvail, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < attrs.length; i++) ...[
            _detailRow(context, attrs.keys.elementAt(i), attrs.values.elementAt(i).toString()),
            if (i < attrs.length - 1) Divider(height: 32, color: AppColors.textSecondary(context).withValues(alpha: 0.1)),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Strip HTML tags from description
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
