import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:realestate/screens/home/modules/categories.dart';
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
import 'modules/budget_filter.dart';

class HomeView2 extends StatefulWidget {
  final bool showNavBar;
  const HomeView2({Key? key, this.showNavBar = true}) : super(key: key);

  @override
  State<HomeView2> createState() => _HomeView2State();
}

class _HomeView2State extends State<HomeView2> {
  final HomeController controller = Get.put(
    HomeController(),
  ); // Init Controller

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
                          SizedBox(height: 16.h),
                          // 2b. Price Range / Budget Filter
                          const BudgetFilterWidget(),
                          // SizedBox(height: 20.h),

                          // // Stats Row
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     _buildStatItem(
                          //       IconlyBold.home,
                          //       "2500+",
                          //       "Premium Homes",
                          //     ),
                          //     SizedBox(width: 20.w),
                          //     _buildStatItem(
                          //       IconlyBold.user_2,
                          //       "100.00+",
                          //       "Premium Customers",
                          //     ),
                          //     // const Spacer(),
                          //     // // Rating Chip
                          //     // Container(
                          //     //   padding: EdgeInsets.symmetric(
                          //     //     horizontal: 12.w,
                          //     //     vertical: 8.h,
                          //     //   ),
                          //     //   decoration: BoxDecoration(
                          //     //     color: const Color(0xFF1E1E1E),
                          //     //     borderRadius: BorderRadius.circular(20.r),
                          //     //     border: Border.all(
                          //     //       color: Colors.white.withOpacity(0.1),
                          //     //     ),
                          //     //   ),
                          //     //   child: Row(
                          //     //     children: [
                          //     //       const Icon(
                          //     //         Icons.star,
                          //     //         color: Colors.orange,
                          //     //         size: 16,
                          //     //       ),
                          //     //       SizedBox(width: 6.w),
                          //     //       Text(
                          //     //         "5.8 (100)",
                          //     //         style: TextStyle(
                          //     //           color: Colors.white,
                          //     //           fontWeight: FontWeight.bold,
                          //     //         ),
                          //     //       ),
                          //     //     ],
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),

                          SizedBox(height: 20.h),

                          // 3. Categories (Dynamic from API with Hierarchical Filtering)
                          Categories(),

                          SizedBox(height: 20.h),

                          // 4. Featured Properties Horizontal List
                          Obx(() => (controller.isLoading.value || (controller.isPropertiesLoading.value && controller.filteredProperties.isEmpty)) 
                              ? const FeaturedShimmer() 
                              : _buildFeaturedPropertiesList()),

                          // SizedBox(height: 30.h),

                          // SizedBox(height: 8.h),
                          // SectionTitle(
                          //   title: "Featured Properties",
                          //   actionText: "View all",
                          //   onActionTap: () {
                          //     Get.toNamed(AppRoutes.featured);
                          //   },
                          // ),
                          // SizedBox(height: 10.h),
                          // // Small listings at bottom
                          // const FeaturedPropertiesList(),

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
                            // actionText: "View all",
                            onActionTap: () => Get.toNamed(AppRoutes.featured),
                          ),
                          SizedBox(height: 16.h),
                          Obx(() => controller.isLoading.value ? const RecommendedShimmer() : const RecommendedProperties()),
                          SizedBox(height: 30.h),

                          // News Section
                          SectionTitle(
                            title: "Updates For You",
                            subtitle: "Read whats happening in Real Estate",
                            actionText: "See all",
                            onActionTap: () => Get.toNamed(AppRoutes.newsList, arguments: controller.newsList),
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
            backgroundImage: CachedNetworkImageProvider("https://i.pravatar.cc/150?img=12"),
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
      () {
        if (controller.isPropertiesLoading.value && controller.filteredProperties.isEmpty) {
           return const FeaturedShimmer();
        }

        if (controller.filteredProperties.isEmpty) {
          return SizedBox(
            height: 320.h,
            child: Center(
              child: Text(
                "No Properties found",
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          );
        }

        final properties = controller.filteredProperties;

        return SizedBox(
          height: 320.h,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: properties.length,
            separatorBuilder: (_, __) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final property = properties[index];
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.propertyDetail, arguments: property.id),
                child: _buildPropertyCard(
                      title: property.title,
                      location: property.address,
                      area: property.area,
                      price: "₹${formatFullPrice(property.price)}",
                      imageUrl: property.mainImageUrl ?? property.mainImage ?? "https://via.placeholder.com/300X320",
                    ),
              )
                  .animate(
                    target: controller.isRefreshing.value ? 0 : 1,
                  ) // Reset animation on refresh
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
            },
          ),
        );
      },
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String location,
    required String area,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      width: 300.w,
      height: 320.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36.r),
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
          // Background Image
          CustomImage(
            imageUrl: imageUrl, 
            width: double.infinity, 
            height: double.infinity,
            borderRadius: 36.r,
          ),

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
            right: 20.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconlyLight.location, color: Colors.white, size: 14.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Content
          Positioned(
            bottom: 10.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                    maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Area/Size
                    Flexible(
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              IconlyLight.discovery,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                area,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

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
                  // onTap: () => Get.toNamed(AppRoutes.propertyDetail),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(30.r),
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
