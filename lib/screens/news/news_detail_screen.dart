import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/models/home_data_model.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from previous screen
    final NewsItem? newsItem = Get.arguments is NewsItem ? Get.arguments as NewsItem : null;
    
    // Fallback if no args (development safety)
    if(newsItem == null) {
        return Scaffold(body: Center(child: Text("No data provided")));
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: scaffoldColor,
            expandedHeight: 300.h,
            pinned: true,
            leading: circleIconButton(context, Icons.arrow_back_ios_new_rounded, () => Get.back()),
            flexibleSpace: FlexibleSpaceBar(
              background: CustomImage(
                imageUrl: newsItem.resourceImage ?? "https://via.placeholder.com/300x320",
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Tags
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: secondary.withOpacity(0.5)),
                          ),
                          child: Text(
                            "Real Estate",
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(IconlyLight.calendar, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('dd MMM, yyyy').format(DateTime.tryParse(newsItem.createdAt) ?? DateTime.now()),
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                        SizedBox(width: 12.w),
                        Icon(IconlyLight.time_circle, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          "5 min read",
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Title
                  Text(
                    newsItem.title,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Divider
                  Divider(color: Colors.white.withOpacity(0.1)),
                  SizedBox(height: 20.h),
                  
                  // Content (Mocked long text)
                  Text(
                    """${newsItem.description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')}
                    
                    """,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade300,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
