import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import '../home/modules/featured_properties_list.dart';

class LocationDetailScreen extends StatelessWidget {
  final String locationName;
  final String rank;
  final String heroImage;
  final String subtitle;

  const LocationDetailScreen({
    Key? key,
    required this.locationName,
    required this.rank,
    required this.heroImage,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== PREMIUM HERO HEADER ====================
          SliverAppBar(
            expandedHeight: 400.h,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 70,
            leading: Padding(
              padding: EdgeInsets.only(left: 20.w, top: 12.h),
              child: _buildCircleButton(
                Icons.arrow_back_ios_new_rounded,
                () => Get.back(),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20.w, top: 12.h),
                child: _buildCircleButton(
                  IconlyLight.send,
                  () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: _buildCleanHeaderGallery(),
            ),
          ),

          // ==================== CONTENT SECTION ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank Badge & Category
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          "RANK #$rank",
                          style: GoogleFonts.inter(
                            color: primary,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Trending Location",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    locationName,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 8.h),

                  // Subtitle/Description
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 32.h),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Exclusive Listings",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Found 128",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  SizedBox(height: 20.h),

                  // Property List (Animate each one)
                  ..._dummyProperties.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var property = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: FeatureCard(
                        imageUrl: property['image'],
                        title: property['title'],
                        location: property['location'],
                        price: property['price'],
                        beds: property['beds'],
                        area: property['area'],
                        tag: property['tag'],
                        rating: property['rating'],
                      )
                          .animate()
                          .fadeIn(delay: (400 + (idx * 100)).ms)
                          .slideY(begin: 0.1, end: 0),
                    );
                  }).toList(),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanHeaderGallery() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main Background Image
        heroImage.startsWith('http')
            ? Image.network(heroImage, fit: BoxFit.cover)
            : Image.asset(heroImage, fit: BoxFit.cover),
        
        // Premium Dark Overlay Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Theme.of(Get.context!).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),

        // Properties Badge
        Positioned(
          bottom: 30.h,
          right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(IconlyLight.home, size: 16.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  "120+ Estates",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> _dummyProperties = [
  {
    "image": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
    "title": "Shree Shyam Kunj",
    "location": "Sector 15, Hisar",
    "price": "12,00,000",
    "beds": "4",
    "area": "250 sq.m",
    "tag": "Luxury",
    "rating": "4.9",
  },
  {
    "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800",
    "title": "Modern Villa",
    "location": "Sector 15, Hisar",
    "price": "45,00,000",
    "beds": "5",
    "area": "400 sq.m",
    "tag": "Trending",
    "rating": "4.8",
  },
  {
    "image": "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
    "title": "The Penthouse",
    "location": "Sector 15, Hisar",
    "price": "85,00,000",
    "beds": "3",
    "area": "200 sq.m",
    "tag": "Elite",
    "rating": "5.0",
  },
];

