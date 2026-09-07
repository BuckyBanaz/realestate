import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String? tag;

  const FullScreenImage({super.key, required this.imageUrl, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary(context),
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary(context),
        iconTheme: IconThemeData(color: AppColors.surfaceLight),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: tag != null
              ? Hero(
                  tag: tag!,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    memCacheWidth: 1080, // full-screen viewer — use screen-res width
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.surfaceLight)),
                    errorWidget: (context, url, error) => Icon(Icons.error, color: AppColors.surfaceLight),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  memCacheWidth: 1080,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.surfaceLight)),
                  errorWidget: (context, url, error) => Icon(Icons.error, color: AppColors.surfaceLight),
                ),
        ),
      ),
    );
  }
}
