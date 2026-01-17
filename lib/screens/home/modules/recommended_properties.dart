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

class RecommendedProperties extends StatelessWidget {
  const RecommendedProperties({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.categoriesWithProperties.isEmpty) {
        return const SizedBox.shrink();
      }
      // For demonstration, taking properties from the first category as "Recommended"
      final properties = controller.categoriesWithProperties.first.properties;

      return SizedBox(
        height: 260.h,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: properties.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final item = properties[index];
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.propertyDetail, arguments: item.id),
              child: Container(
                width: 220.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Container
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Stack(
                        children: [
                          CustomImage(
                            imageUrl: item.propertyImage ?? "https://via.placeholder.com/220x140",
                            height: 140.h,
                            width: double.infinity,
                            borderRadius: 20.r,
                          ),
                          // Rating Badge
                          // Positioned(
                          //   top: 8.h,
                          //   right: 8.w,
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          //     decoration: BoxDecoration(
                          //       color: Colors.black.withOpacity(0.6),
                          //       borderRadius: BorderRadius.circular(12.r),
                          //     ),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          //         SizedBox(width: 4.w),
                          //         Text(
                          //           "4.5",
                          //           style: TextStyle(
                          //             color: Colors.white,
                          //             fontSize: 10.sp,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Details
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(IconlyLight.location, size: 12.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  item.address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${formatPrice(item.price)}",
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.crop_square_outlined, size: 14.sp, color: Colors.grey.shade400),
                                  SizedBox(width: 4.w),
                                  Text(item.area, style: TextStyle(color: Colors.grey.shade400, fontSize: 10.sp)),
                                ],
                              )
                            ],
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
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
          },
        ),
      );
    });
  }
}
