import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:realestate/screens/widgets/helpers.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    String formatDate(String raw) {
      final cleaned = raw.trim();
      if (cleaned.isEmpty) return '-';
      final normalized = cleaned.endsWith('Z') ? cleaned : '${cleaned}Z';
      final parsed =
          DateTime.tryParse(normalized) ?? DateTime.tryParse(cleaned);
      if (parsed == null) return raw;
      return DateFormat('dd MMM yyyy').format(parsed.toLocal());
    }

    return Obx(
      () => SizedBox(
        height: 220.h,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: controller.newsList.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final item = controller.newsList[index];
            final isVideo = item.type.toLowerCase() == 'video';
            return (isVideo
                    ? _VideoNewsCard(
                        item: item,
                        onTap: () async {
                          final url = item.videoUrl ?? '';
                          final uri = Uri.tryParse(url);
                          if (uri != null) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      )
                    : _ResourceNewsCard(
                        item: item,
                        onTap: () => Get.toNamed(
                          AppRoutes.newsDetail,
                          arguments: item,
                        ),
                        formatDate: formatDate,
                      ))
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
          },
        ),
      ),
    );
  }
}

class _VideoNewsCard extends StatelessWidget {
  const _VideoNewsCard({
    required this.item,
    required this.onTap,
  });

  final dynamic item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CustomImage(
                  imageUrl:
                      item.resourceImage ?? "https://via.placeholder.com/260x140",
                  height: 110.h,
                  width: double.infinity,
                  borderRadius: 16.r,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 36.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10.w,
                  bottom: 10.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.play,
                          size: 14.sp,
                          color: secondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Watch now',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            IconlyLight.arrow_right_2,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceNewsCard extends StatelessWidget {
  const _ResourceNewsCard({
    required this.item,
    required this.onTap,
    required this.formatDate,
  });

  final dynamic item;
  final VoidCallback onTap;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImage(
              imageUrl:
                  item.resourceImage ?? "https://via.placeholder.com/260x140",
              height: 110.h,
              width: double.infinity,
              borderRadius: 16.r,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.time_circle,
                          size: 14.sp,
                          color: secondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          formatDate(item.createdAt),
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            IconlyLight.arrow_right_2,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
