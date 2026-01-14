import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/screens/home/modules/search_text_field.dart';
import 'modules/news_section.dart';
import 'modules/section_title.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'modules/featured_properties_list.dart';
import 'package:iconly/iconly.dart';
import 'modules/top_locations_section.dart';
import 'modules/recommended_properties.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/controllers/home_controller.dart'; // Import controller
import '../widgets/shimmers.dart';

class HomeView2 extends StatefulWidget {
  final bool showNavBar;
  const HomeView2({Key? key, this.showNavBar = true}) : super(key: key);

  @override
  State<HomeView2> createState() => _HomeView2State();
}

class _HomeView2State extends State<HomeView2> {
  int _selectedCategoryIndex = 0;
  final HomeController controller = Get.put(
    HomeController(),
  ); // Init Controller

  final List<String> categories = [
    "FLATS / HOUSING",
    "TOWNSHIPS",
    "FARM HOUSES",
    "SOCIETIES",
    "PLOTS",
    "AGRI LAND",
  ];

  @override
  Widget build(BuildContext context) {
    // Ensuring we are using the dark theme colors from your app_theme
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Gradient Element (Subtle glow)
          Positioned(
            top: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withOpacity(0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: controller.onRefresh,
              color: secondary, // Gold spinner
              backgroundColor: const Color(0xFF222222), // Dark box
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header (Logo + Menu) - Now inside scroll view
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        children: [
                          // Animated Logoor from helpers
                          const Logoor(animate: true),
                          const Spacer(),
                          // Notification Button
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.notification),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconlyLight.notification,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          // 2. Search Bar
                          const SearchTextField(),
                          SizedBox(height: 20.h),

                          // Stats Row
                          Row(
                            children: [
                              _buildStatItem(
                                IconlyBold.home,
                                "2500+",
                                "Premium Homes",
                              ),
                              SizedBox(width: 20.w),
                              _buildStatItem(
                                IconlyBold.user_2,
                                "100.00+",
                                "Premium Customers",
                              ),
                              const Spacer(),
                              // Rating Chip
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "5.8 (100)",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30.h),

                          // 3. Categories
                          SizedBox(
                            height: 38.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                final isSelected =
                                    _selectedCategoryIndex == index;
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCategoryIndex = index,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primary.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? primary
                                            : Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      categories[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? primary
                                            : Colors.grey.shade500,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 30.h),

                          // 4. Featured Properties Horizontal List
                          Obx(() => controller.isLoading.value ? const FeaturedShimmer() : _buildFeaturedPropertiesList()),

                          SizedBox(height: 30.h),

                          SizedBox(height: 8.h),
                          SectionTitle(
                            title: "Featured Properties",
                            actionText: "View all",
                            onActionTap: () {
                              Get.toNamed(AppRoutes.featured);
                            },
                          ),
                          SizedBox(height: 10.h),
                          // Small listings at bottom
                          const FeaturedPropertiesList(),

                          SizedBox(height: 30.h),
                          SectionTitle(
                            title: "Top Locations",
                            actionText: "Explore",
                            onActionTap: () {
                              Get.toNamed(AppRoutes.topLocations);
                            },
                          ),

                          SizedBox(height: 10.h),
                          Obx(() => controller.isLoading.value ? const TopLocationsShimmer() : const TopLocationsSection()),
                          SizedBox(height: 30.h),

                          // Recommended Section
                          SectionTitle(
                            title: "Recommended for you",
                            actionText: "View all",
                            onActionTap: () => Get.toNamed(AppRoutes.featured),
                          ),
                          SizedBox(height: 16.h),
                          Obx(() => controller.isLoading.value ? const RecommendedShimmer() : const RecommendedProperties()),
                          SizedBox(height: 30.h),

                          // News Section
                          SectionTitle(
                            title: "News For You",
                            subtitle: "Read whats happening in real estate",
                            actionText: "See all",
                            onActionTap: () => Get.toNamed(AppRoutes.newsList),
                          ),
                          SizedBox(height: 16.h),
                          Obx(() => controller.isLoading.value ? const NewsShimmer() : const NewsSection()),

                          SizedBox(height: 100.h), // space for bottom nav
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Floating Bottom Navbar
          if (widget.showNavBar)
            Positioned(
              bottom: 30.h,
              left: 20.w,
              right: 20.w,
              child: _buildFloatingBottomNav(),
            ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: secondary, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10.sp),
        ),
      ],
    );
  }



  Widget _buildFloatingBottomNav() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(35.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(IconlyBold.home, true),
          _navItem(IconlyLight.document, false),
          // Center FAB
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(IconlyBold.location, color: Colors.white, size: 24.sp),
          ),
          _navItem(IconlyLight.heart, false),
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
          ),
          // _navItem(IconlyLight.profile, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? secondary : Colors.grey.shade600,
          size: 24.sp,
        ),
        if (isActive)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(color: secondary, shape: BoxShape.circle),
          ),
      ],
    );
  }

  // Featured Properties Horizontal List
  Widget _buildFeaturedPropertiesList() {
    return Obx(
      () => SizedBox(
        height: 320.h,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: controller.featuredProperties.length,
          separatorBuilder: (_, __) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final property = controller.featuredProperties[index];
            return _buildPropertyCard(
                  title: property["title"]!,
                  location: property["location"]!,
                  bedrooms: property["bedrooms"]!,
                  bathrooms: property["bathrooms"]!,
                  price: property["price"]!,
                  imageUrl: property["image"]!,
                )
                .animate(
                  target: controller.isRefreshing.value ? 0 : 1,
                ) // Reset animation on refresh
                .fadeIn(delay: (100 * index).ms)
                .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
          },
        ),
      ),
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String location,
    required String bedrooms,
    required String bathrooms,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      width: 300.w,
      height: 320.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36.r),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

          // Top Location Tag
          Positioned(
            top: 20.h,
            left: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(IconlyLight.location, color: Colors.white, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    location,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content
          Positioned(
            bottom: 24.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Attributes and Price Row
                Row(
                  children: [
                    // Bedroom
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bed_outlined,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "$bedrooms Bed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Bathroom
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bathtub_outlined,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "$bathrooms Bath",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Price
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: secondary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        price,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.propertyDetail),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(30.r),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: secondary.withOpacity(0.4),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wrap content width
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "View Details",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
