import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../utils/safe_cache_manager.dart';

/// Shared image carousel used on both the home card and the detail screen.
/// Matches the detail screen's exact look: gradient overlay, dot indicators,
/// optional tap-to-zoom callback, optional Hero tags.
class PropertyImageCarousel extends StatefulWidget {
  final List<String> images;
  final int plotId;

  /// Called when the user taps an image. Receives (imageUrl, heroTag).
  /// Pass null to disable tap-to-zoom (e.g. on home cards).
  final void Function(String url, String heroTag)? onTap;

  /// Bottom offset for dot indicators. Detail screen uses 56 (above title),
  /// home cards use 8.
  final double dotBottomOffset;

  const PropertyImageCarousel({
    super.key,
    required this.images,
    required this.plotId,
    this.onTap,
    this.dotBottomOffset = 8,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  final ValueNotifier<int> _current = ValueNotifier<int>(0);
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: widget.images.length,
          onPageChanged: (i) => _current.value = i,
          itemBuilder: (_, i) {
            final tag = 'plot-image-${widget.plotId}-$i';
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null
                  ? () => widget.onTap!(widget.images[i], tag)
                  : null,
              child: RepaintBoundary(
                child: Hero(
                  tag: tag,
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i],
                    cacheManager: SafeCacheManager(),
                    fit: BoxFit.cover,
                    memCacheWidth: 600, // enough for card display, saves RAM vs 800
                    placeholder: (_, __) => Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.apartment_rounded, color: AppColors.primary, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Gradient overlay — same as detail screen
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Dot indicators
        if (widget.images.length > 1)
          Positioned(
            bottom: widget.dotBottomOffset,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _current,
              builder: (context, currentIdx, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) => Container(
                    width: currentIdx == i ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: currentIdx == i ? AppColors.surfaceLight : AppColors.surfaceLight.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                );
              },
            ),
          ),
      ],
    );
  }
}
