import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class TopLocationsSection extends StatelessWidget {
  const TopLocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        scrollDirection: Axis.horizontal,
        itemCount: topLocations.length,
        clipBehavior: Clip.none,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final location = topLocations[index];
          return LocationCard(
            imageUrl: location["image"]!,
            title: location["title"]!,
            listings: "25+",
            onTap: () {
              Get.toNamed(
                AppRoutes.topLocations,
                arguments: {
                  'locationName': location["title"]!.replaceAll('\n', ' '),
                  'rank': "+${index + 1}",
                  'heroImage': location["image"]!,
                  'subtitle':
                      "Our recommended real estates in ${location["title"]!.split(',').first}",
                },
              );
            },
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
        },
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
        height: 125.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
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
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade900,
                      child: Icon(IconlyLight.image, color: Colors.grey.shade700),
                    ),
                  ),
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

// ---------------- sample data ----------------
final List<Map<String, String>> topLocations = [
  {
    "title": "Sector 15, Hisar",
    "image":
        "https://images.unsplash.com/photo-1599423300746-b62533397364?w=600",
  },
  {
    "title": "Hisar Cantt",
    "image":
        "https://images.unsplash.com/photo-1600585153490-76fb20a32601?w=600",
  },
  {
    "title": "Rajguru Nagar, Hisar",
    "image":
        "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600",
  },
  {
    "title": "Model Town, Hisar",
    "image":
        "https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=600",
  },
];

