import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/home_controller.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class TopLocationsScreen extends StatelessWidget {
  const TopLocationsScreen({Key? key}) : super(key: key);

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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  
                  // ==================== HEADER ====================
                  Text(
                    "Top Regions",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),

                  SizedBox(height: 8.h),

                  Text(
                    "Discover the most prestigious neighborhoods and high-growth areas in Hisar.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1, end: 0),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // ==================== GRID OF LOCATIONS ====================
          Obx(() {
            final controller = Get.find<HomeController>();
            if (controller.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.topLocations.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text("No locations found")),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final loc = controller.topLocations[index];
                    return _LocationCard(
                      rank: (index + 1).toString().padLeft(2, '0'),
                      title: loc.title,
                      imageUrl: loc.propertyImage ?? "",
                      listingCount: loc.address,
                      addressId: loc.id,
                    )
                        .animate()
                        .fadeIn(delay: (200 + (index * 100)).ms)
                        .slideY(begin: 0.1, end: 0)
                        .scale(begin: const Offset(0.9, 0.9));
                  },
                  childCount: controller.topLocations.length,
                ),
              ),
            );
          }),
          
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String rank, title, imageUrl, listingCount;
  final int addressId;

  const _LocationCard({
    required this.rank,
    required this.title,
    required this.imageUrl,
    required this.listingCount,
    required this.addressId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.locationDetail,
          arguments: {
            'locationName': title,
            'rank': rank,
            'heroImage': imageUrl,
            'subtitle': listingCount,
            'addressId': addressId,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Image
              CustomImage(
                imageUrl: imageUrl.startsWith('http') ? imageUrl : "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600",
                width: double.infinity,
                height: double.infinity,
                borderRadius: 24.r,
                errorWidget: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),

              // Premium Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0, 0.5, 1.0],
                  ),
                ),
              ),

              // Rank Badge (Top Left)
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: Text(
                    rank,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Content (Bottom)
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.split(',').first,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(IconlyLight.location, size: 12.sp, color: primary),
                        SizedBox(width: 4.w),
                        Expanded(
                            child: Text(
                              listingCount,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

