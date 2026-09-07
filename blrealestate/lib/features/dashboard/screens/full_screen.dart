import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../../../core/constants/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _resetAnimation;

  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformController.value = _resetAnimation!.value;
        }
      });

    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _resetZoom() {
    _resetAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: AppColors.textPrimary(context).withValues(alpha: 0.5),
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.surfaceLight),
            actions: [
              IconButton(
                icon: Icon(Icons.zoom_out_map_rounded, color: AppColors.surfaceLight),
                tooltip: AppStrings.resetZoom,
                onPressed: _resetZoom,
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 6.0,
              panEnabled: true,
              scaleEnabled: true,
              onInteractionEnd: (_) {
                // If zoomed out below 1x, snap back to fit
                final scale = _transformController.value.getMaxScaleOnAxis();
                if (scale < 1.0) _resetZoom();
              },
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                cacheManager: SafeCacheManager(),
                fit: BoxFit.contain,
                memCacheWidth: 1080, // full-screen viewer — use screen-res width
                placeholder: (_, _) => Center(
                  child: CircularProgressIndicator(color: AppColors.surfaceLight.withValues(alpha: 0.54)),
                ),
                errorWidget: (_, _, _) => Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.surfaceLight.withValues(alpha: 0.54),
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
