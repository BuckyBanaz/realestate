import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import '../../../../data/controllers/home_controller.dart';

import 'package:realestate/screens/widgets/helpers.dart';

class TopLocationsSection extends StatelessWidget {
  const TopLocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(
      () => SizedBox(
        height: 140.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.topLocations.length,
          clipBehavior: Clip.none,
          separatorBuilder: (_, __) => SizedBox(width: 14.w),
          itemBuilder: (context, index) {
            final location = controller.topLocations[index];
            return LocationCard(
              imageUrl: location.propertyImage ?? "https://via.placeholder.com/300x140",
              title: location.title,
              listings: "Explore",
              onTap: () {
                Get.toNamed(
                  AppRoutes.locationDetail,
                  arguments: {
                    'locationName': location.title,
                    'rank': "+${index + 1}",
                    'heroImage': location.propertyImage,
                    'subtitle': location.address,
                    'addressId': location.id,
                  },
                );
              },
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

class LocationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String listings;
  final VoidCallback? onTap;

  const LocationCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.listings,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300.w,
        height: 140.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Slightly lighter? Or keep 1A1A1A
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Section
            Hero(
              tag: imageUrl + title,
              child: CustomImage(
                imageUrl: imageUrl,
                width: 110.w,
                height: 116.h,
                borderRadius: 20.r,
                errorWidget: (context, url, _) => Container(
                  color: Colors.grey.shade900,
                  child: Icon(IconlyLight.image, color: Colors.grey.shade700),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "TOP REGION",
                      style: GoogleFonts.inter(
                        color: secondary,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(IconlyLight.location, size: 12.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        "Hisar, Haryana",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(IconlyBold.category, size: 10.sp, color: primary),
                            SizedBox(width: 4.w),
                            Text(
                              "$listings Estates",
                              style: GoogleFonts.inter(
                                color: primary,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        IconlyLight.arrow_right_2,
                        size: 14.sp,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


