import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data for News
    final List<Map<String, String>> news = [
      {
        "title": "BMC announces first housing lottery; to give 426 Mumbai flats",
        "date": "24 Jan",
        "readTime": "7 min read",
        "image": "https://img.freepik.com/free-photo/toy-bricks-table-with-word-news_144627-47476.jpg", 
        "description": "The BMC Housing Lottery is offering houses in Kandivali, Bhandup, and more..."
      },
      {
        "title": "Real Estate market sees a boom in Q1 2025",
        "date": "22 Jan",
        "readTime": "5 min read",
        "image": "https://img.freepik.com/free-photo/graph-chart-growth-analysis-concept_53876-120302.jpg",
        "description": "Experts predict a sharp rise in property prices across tier-1 cities."
      },
      {
        "title": "New Metro line boosts property rates in Pune",
        "date": "20 Jan",
        "readTime": "4 min read",
        "image": "https://img.freepik.com/free-photo/city-skyline-landmarks-urban-scene_1112-887.jpg",
        "description": "Connectivity improvements lead to a surge in demand for residential units."
      },
    ];

    return SizedBox(
      height: 300.h,
      child: ListView.separated(
        padding: EdgeInsets.zero, 
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: news.length,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final item = news[index];
          return GestureDetector(
            onTap: () {
               Get.toNamed(AppRoutes.newsDetail, arguments: item);
            },
            child: Container(
              width: 260.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Slightly lighter dark
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                        child: Image.network(
                          item["image"]!,
                          height: 140.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Date Badge
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            item["date"]!,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp, // Slightly reduced
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item["description"]!,
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
                                item["readTime"]!,
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
                                  border: Border.all(color: Colors.white24)
                                ),
                                child: Icon(IconlyLight.arrow_right_2, size: 12.sp, color: Colors.white),
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
    );
  }
}
