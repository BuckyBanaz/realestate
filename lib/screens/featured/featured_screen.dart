import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/search/search_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../home/home_screen.dart';
import '../home/modules/featured_properties_list.dart';
import '../home/modules/search_text_field.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/Routes/appRoutes.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Premium Transparent AppBar
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            leadingWidth: 70,
            leading: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyLight.filter,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),

                  // ==================== HERO IMAGE GALLERY ====================
                  _buildStaggeredHeroGallery(context)
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOutQuad)
                      .slideY(begin: 0.1, end: 0),

                  SizedBox(height: 30.h),

                  // ==================== TITLE + SUBTITLE ====================
                  Text(
                    "Featured Estates",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                  SizedBox(height: 8.h),

                  Text(
                    "Our recommended real estates exclusive for you.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),

                  SizedBox(height: 28.h),

                  // ==================== SEARCH BAR ====================
                  const SearchTextField()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scale(begin: Offset(0.95, 0.95)),

                  SizedBox(height: 24.h),

                  // ==================== ESTATES COUNT & GRID CONTROLS ====================
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: secondary.withOpacity(0.3)),
                        ),
                        child: Text(
                          "70 estates",
                          style: TextStyle(
                            color: secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildIconControl(IconlyLight.filter_2),
                      SizedBox(width: 12.w),
                      _buildIconControl(Icons.grid_view_rounded),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  SizedBox(height: 24.h),

                  // ==================== LIST OF ESTATES ====================
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: estatesData.length,
                    separatorBuilder: (_, __) => SizedBox(height: 20.h),
                    itemBuilder: (ctx, index) {
                      final data = estatesData[index];
                      return FeatureCard(
                        imageUrl: data["image"]!,
                        title: data["name"]!,
                        rating: data["rating"]!,
                        location: data["loc"]!,
                        price: data["price"]!,
                        tag: data["tag"]!,
                        beds: data["beds"]!,
                        area: data["area"]!,
                      )
                          .animate()
                          .fadeIn(delay: (600 + (index * 100)).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconControl(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }

  // Refined Hero Gallery
  Widget _buildStaggeredHeroGallery(BuildContext context) {
    // High quality imagery
    final images = [
      "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600",
      "https://images.unsplash.com/photo-1600596542815-e32c8ec049db?w=600",
      "https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600",
    ];

    final double totalW = MediaQuery.of(context).size.width - 40.w;
    final double leftW = totalW * 0.62;
    final double rightW = totalW - leftW - 12.w;
    final double leftH = 220.h;
    final double rightH = 100.h;

    return SizedBox(
      height: 220.h + 100.h * 0.4, // accommodate overlap
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Left Large Image
          Positioned(
            left: 0,
            top: 0,
            child: _galleryImage(images[0], leftW, leftH, 24),
          ),
          // Top Right Small
          Positioned(
            right: 0,
            top: 15.h,
            child: _galleryImage(images[1], rightW, rightH, 18),
          ),
          // Bottom Right Small Overlap
          Positioned(
            right: 15.w,
            bottom: 0,
            child: _galleryImage(images[2], rightW * 1.1, rightH * 1.1, 18),
          ),
        ],
      ),
    );
  }

  Widget _galleryImage(String url, double w, double h, double radius) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey.shade900),
        ),
      ),
    );
  }
}




final List<Map<String, String>> estatesData = [
  {
    "name": "Urban Heights Apartment",
    "rating": "4.8",
    "loc": "Sector 15, Hisar",
    "price": "230",
    "tag": "Apartment",
    "image": "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    "beds": "3 BHK",
    "area": "180 sq.m"
  },
  {
    "name": "The Aurelia Villa - Hisar",
    "rating": "4.9",
    "loc": "Rajguru Nagar, Hisar",
    "price": "520",
    "tag": "Villa",
    "image": "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
    "beds": "5 BHK",
    "area": "400 sq.m"
  },
  {
    "name": "Mill Sper House (Hisar)",
    "rating": "4.7",
    "loc": "Model Town, Hisar",
    "price": "271",
    "tag": "House",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
    "beds": "4 BHK",
    "area": "250 sq.m"
  },
  {
    "name": "Wings Tower Hisar",
    "rating": "4.6",
    "loc": "Camp Chowk, Hisar",
    "price": "220",
    "tag": "Apartment",
    "image": "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
    "beds": "2 BHK",
    "area": "120 sq.m"
  },
  {
    "name": "Green Valley Residence",
    "rating": "4.7",
    "loc": "Hisar Cantt",
    "price": "350",
    "tag": "Villa",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
    "beds": "3 BHK",
    "area": "210 sq.m"
  },
];
