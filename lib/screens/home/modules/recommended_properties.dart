import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecommendedProperties extends StatelessWidget {
  const RecommendedProperties({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> properties = [
      {
        "title": "Skyline Haven",
        "location": "Sector 45, Gurgaon",
        "price": "\$8,500",
        "rating": 4.8,
        "image": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 3,
        "baths": 2,
        "area": "1200 sqft"
      },
      {
        "title": "Urban Loft",
        "location": "Whitefield, Bangalore",
        "price": "\$6,200",
        "rating": 4.5,
        "image": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 2,
        "baths": 1,
        "area": "950 sqft"
      },
      {
        "title": "Serenity Villa",
        "location": "Lonavala, Pune",
        "price": "\$12,000",
        "rating": 4.9,
        "image": "https://images.unsplash.com/photo-1613490493576-7fde63acd811?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 4,
        "baths": 4,
        "area": "3500 sqft"
      },
       {
        "title": "Palm Heights",
        "location": "Bandra West, Mumbai",
        "price": "\$9,000",
        "rating": 4.7,
        "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 3,
        "baths": 2,
        "area": "1500 sqft"
      },
    ];

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
            onTap: () => Get.toNamed(AppRoutes.propertyDetail),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.network(
                            item["image"],
                            height: 140.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Rating Badge
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 12.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  "${item['rating']}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Favorite Icon
                        // Positioned(
                        //   top: 8.h,
                        //   left: 8.w,
                        //   child: Container(
                        //     padding: EdgeInsets.all(6.w),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white.withOpacity(0.2),
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: Icon(IconlyLight.heart, color: Colors.white, size: 16.sp),
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
                          item["title"],
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
                                item["location"],
                                maxLines: 1,
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
                              item["price"],
                              style: TextStyle(
                                color: secondary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                               children: [
                                Icon(Icons.bed_outlined, size: 14.sp, color: Colors.grey.shade400,),
                                SizedBox(width: 4.w),
                                Text("${item['beds']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
                                SizedBox(width: 8.w),
                                Icon(Icons.bathtub_outlined, size: 14.sp, color: Colors.grey.shade400,),
                                SizedBox(width: 4.w),
                                Text("${item['baths']}", style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
                               ]
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
  }
}
