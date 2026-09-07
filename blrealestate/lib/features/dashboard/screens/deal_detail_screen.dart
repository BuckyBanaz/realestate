import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../../../models/app_models.dart';
import 'full_screen.dart';

class DealDetailScreen extends StatelessWidget {
  final DealModel deal;
  const DealDetailScreen({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isLarge = size.width >= 600;
    final hPad = isSmall ? 16.0 : isLarge ? 40.0 : 24.0;

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: isLarge ? 360 : 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: AppColors.surfaceLight),
              flexibleSpace: FlexibleSpaceBar(
                background: deal.bannerImage != null
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: deal.bannerImage!,
                              heroTag: 'deal-image-${deal.id}',
                            ),
                          ),
                        ),
                        // Hero tag must match the heroTag passed to FullScreenImageViewer
                        child: Hero(
                          tag: 'deal-image-${deal.id}',
                          child: CachedNetworkImage(
                            imageUrl: deal.bannerImage!,
                            cacheManager: SafeCacheManager(),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.textSecondary(context),
                              child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textSecondary(context)),
                            ),
                            placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.textSecondary(context),
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(hPad),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    deal.title,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.dealPrefix}${deal.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 24),
                    Text(
                      AppStrings.aboutDeal,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deal.description.isEmpty ? 'No description available' : deal.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.associatedProp,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.apartment, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                deal.propertyTitle,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  Text(
                    'Created: ${DateFormatter.format(deal.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
    );
  }
}
