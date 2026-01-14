import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
class NewsListScreen extends StatelessWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data (Ideally this would come from a provider/controller)
    final List<Map<String, String>> allNews = [
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
       {
        "title": "Sustainable Housing: The Future of Real Estate",
        "date": "18 Jan",
        "readTime": "6 min read",
        "image": "https://img.freepik.com/free-photo/eco-house-concept-with-green-grass_23-2148439463.jpg",
        "description": "More developers are opting for green building materials as demand for eco-friendly homes rises."
      },
      {
        "title": "Home Loan Interest Rates likely to drop",
        "date": "15 Jan",
        "readTime": "3 min read",
        "image": "https://img.freepik.com/free-photo/coins-glass-jar-with-growing-plant_23-2148536856.jpg",
        "description": "The central bank signals a possible reduction in repo rates next month."
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: circleIconButton(context, Icons.arrow_back_ios_new_rounded, () => Get.back()),
        title: Text(
          "Latest News",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: allNews.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (context, index) {
          final item = allNews[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: item),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                    child: Image.network(
                      item["image"]!,
                      width: 120.w,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item["title"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(IconlyLight.calendar, size: 12.sp, color: Colors.grey),
                              SizedBox(width: 4.w),
                              Text(
                                item["date"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                ),
                              ),
                              const Spacer(),
                              Icon(IconlyLight.time_circle, size: 12.sp, color: secondary),
                              SizedBox(width: 4.w),
                              Text(
                                item["readTime"]!,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
