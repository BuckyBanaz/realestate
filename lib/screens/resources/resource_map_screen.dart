import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/resources_controller.dart';
import 'package:realestate/screens/resources/resource_map_detail_screen.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceMapScreen extends StatelessWidget {
  const ResourceMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResourcesController());

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          'Resource Map',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.resources.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.resources.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchResources,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: Text(
                    'No resources found',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchResources,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: controller.resources.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final item = controller.resources[index];
              final isVideo = item.type.toLowerCase() == 'video';
              final thumbnailUrl = item.resourceImage ?? '';
              return GestureDetector(
                    onTap: () async {
                      if (isVideo) {
                        final url = item.videoUrl ?? '';
                        final uri = Uri.tryParse(url);
                        if (uri != null) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        return;
                      }
                      final imageUrl = item.resourceImage ?? '';
                      if (imageUrl.isEmpty) return;
                      Get.to(
                        () => ResourceMapDetailScreen(
                          title: item.title,
                          imageUrl: imageUrl,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18.r),
                            ),
                            child: SizedBox(
                              height: 180.h,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (thumbnailUrl.isNotEmpty)
                                    CustomImage(
                                      imageUrl: thumbnailUrl,
                                      height: 180.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Container(
                                      color: Colors.black26,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.white54,
                                        size: 32.sp,
                                      ),
                                    ),
                                  if (isVideo)
                                    Container(
                                      color: Colors.black26,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: Colors.white,
                                        size: 48.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              children: [
                                if (isVideo) ...[
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: secondary,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                ],
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
            },
          ),
        );
      }),
    );
  }
}
