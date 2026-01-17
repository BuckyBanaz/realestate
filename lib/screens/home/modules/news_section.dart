import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/controllers/home_controller.dart';

import 'package:realestate/screens/widgets/helpers.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(
      () => SizedBox(
        height: 300.h,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: controller.newsList.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final item = controller.newsList[index];
            return GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.newsDetail, arguments: item);
              },
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
                    // Image Section
                    CustomImage(
                      imageUrl: item.resourceImage ?? "https://via.placeholder.com/260x140",
                      height: 140.h,
                      width: double.infinity,
                      borderRadius: 16.r, // Note: simplifying to full radius or I could use a custom clipper
                    ),

                    // Content Section
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
                            SizedBox(height: 6.h),
                            Text(
                              // Removing HTML tags from description if present
                              item.description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ''),
                              maxLines: 2,
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
                                Icon(IconlyLight.time_circle, size: 14.sp, color: secondary),
                                SizedBox(width: 4.w),
                                Text(
                                  "News",
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
                                      border: Border.all(color: Colors.white24)),
                                  child: Icon(IconlyLight.arrow_right_2,
                                      size: 12.sp, color: Colors.white),
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
            )
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
          },
        ),
      ),
    );
  }
}
