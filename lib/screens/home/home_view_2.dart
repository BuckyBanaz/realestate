import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/screens/home/modules/search_text_field.dart';
import 'modules/section_title.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'modules/featured_properties_list.dart';
import 'package:iconly/iconly.dart';
import 'modules/top_locations_section.dart';
class HomeView2 extends StatefulWidget {
  final bool showNavBar;
  const HomeView2({Key? key, this.showNavBar = true}) : super(key: key);

  @override
  State<HomeView2> createState() => _HomeView2State();
}

class _HomeView2State extends State<HomeView2> {
  int _selectedCategoryIndex = 0;

  final List<String> categories = ["FLATS / HOUSING", "TOWNSHIPS", "FARM HOUSES", "SOCIETIES","PLOTS", "AGRI LAND"];

  @override
  Widget build(BuildContext context) {
    // Ensuring we are using the dark theme colors from your app_theme
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textC = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Logo + Menu)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
                          child: Icon(IconlyLight.notification,
                              color: Colors.white, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
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
                            _buildStatItem(IconlyBold.home, "2500+", "Premium Homes"),
                            SizedBox(width: 20.w),
                            _buildStatItem(
                                IconlyBold.user_2, "100.00+", "Premium Customers"),
                            const Spacer(),
                            // Rating Chip
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20.r),
                                border:
                                    Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "5.8 (100)",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
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
                              final isSelected = _selectedCategoryIndex == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        _buildFeaturedPropertiesList(),

                        SizedBox(height: 30.h),

                        // 5. Bottom List Title
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Nearby Your Location",
                        //       style: TextStyle(
                        //         fontSize: 18.sp,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     Text(
                        //       "View all",
                        //       style: TextStyle(color: secondary, fontSize: 14.sp),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 16.h),
                         SizedBox(height: 8.h),
                        SectionTitle(
                    title: "FEATURED PROPERTIES",
                    actionText: "View all",
                    onActionTap: () {
                      Get.toNamed(AppRoutes.featured);
                    },
                  ),
                 SizedBox(height: 10.h),
                        // Small listings at bottom
                        const FeaturedPropertiesList(),


SizedBox(height:30.h),
                        SectionTitle(
                    title: "TOP LOCATIONS",
                    actionText: "Explore",
                    onActionTap: () {
                      Get.toNamed(AppRoutes.topLocations);
                    },
                  ),
               
                   SizedBox(height: 10.h),
                      const TopLocationsSection(),
                        SizedBox(height: 100.h), // space for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildFeaturedGlassCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36.r),
        image: const DecorationImage(
          image: NetworkImage(
              "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg"), // Placeholder
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
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
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
                children: [
                  Icon(IconlyLight.location, color: Colors.white, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    "7866, Near star", // Random placeholder from image
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
                  "Grand Larts",
                  style: GoogleFonts.inter(
                    fontSize: 26.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bed_outlined, size: 14.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            "3 Bedroom",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    
                    // Bathroom
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bathtub_outlined, size: 14.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            "2 Bath",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Price
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: secondary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "\$5400",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // Action Button (Slide to look / View)
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.propertyDetail),
                  child: Container(
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.near_me_outlined, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          "View Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
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

  Widget _glassStat(String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6.w, color: secondary),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildBottomListCard() {
    return Container(
      width: double.infinity,
      height: 100.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(
              "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400",
              width: 80.w,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Malvea plots",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "2.5 • 88 reviews",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          _circleMiniBtn(IconlyLight.heart),
          SizedBox(width: 8.w),
          _circleMiniBtn(IconlyLight.arrow_right_2),
        ],
      ),
    );
  }

  Widget _circleMiniBtn(IconData icon) {
    return Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp));
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
              boxShadow: [BoxShadow(color: secondary.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Icon(IconlyBold.location, color: Colors.white, size: 24.sp),
          ),
          _navItem(IconlyLight.heart, false),
          const CircleAvatar(
             radius: 14,
             backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
          )
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
          )
      ],
    );
  }



  // Featured Properties Horizontal List
  Widget _buildFeaturedPropertiesList() {
    final properties = [
      {
        "title": "Grand Larts",
        "location": "7866, Near star",
        "bedrooms": "3",
        "bathrooms": "2",
        "price": "\$5400",
        "image": "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
      },
      {
        "title": "Shree Shyam Kunj",
        "location": "Sector 15, Hisar",
        "bedrooms": "4",
        "bathrooms": "3",
        "price": "\$6200",
        "image": "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
      },
      {
        "title": "Fairview Apartment",
        "location": "Hisar Cantt",
        "bedrooms": "2",
        "bathrooms": "2",
        "price": "\$4800",
        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
      },
      {
        "title": "Rajguru Farmhouse",
        "location": "Rajguru Nagar",
        "bedrooms": "5",
        "bathrooms": "4",
        "price": "\$7500",
        "image": "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
      },
      {
        "title": "Green Valley",
        "location": "Model Town",
        "bedrooms": "3",
        "bathrooms": "2",
        "price": "\$5100",
        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
      },
    ];

    return SizedBox(
      height: 320.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: properties.length,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final property = properties[index];
          return _buildPropertyCard(
            title: property["title"]!,
            location: property["location"]!,
            bedrooms: property["bedrooms"]!,
            bathrooms: property["bathrooms"]!,
            price: property["price"]!,
            imageUrl: property["image"]!,
          );
        },
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
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bed_outlined, size: 14.sp, color: Colors.white),
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bathtub_outlined, size: 14.sp, color: Colors.white),
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
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.near_me_outlined, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          "View Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
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


