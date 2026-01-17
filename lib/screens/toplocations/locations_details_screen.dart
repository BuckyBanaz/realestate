import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/location_details_controller.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import '../home/modules/featured_properties_list.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationName;
  final String rank;
  final String heroImage;
  final String subtitle;
  final int addressId;

  const LocationDetailScreen({
    Key? key,
    required this.locationName,
    required this.rank,
    required this.heroImage,
    required this.subtitle,
    required this.addressId,
  }) : super(key: key);

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  final LocationDetailsController controller = Get.put(LocationDetailsController());

  @override
  void initState() {
    super.initState();
    controller.fetchLocationDetails(widget.addressId);
  }

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
                          "RANK #${widget.rank}",
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
                  Obx(() => Text(
                    controller.locationData.value?.address ?? widget.locationName,
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  )).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 8.h),

                  // Subtitle/Description
                  Text(
                    widget.subtitle,
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
                      Obx(() => Text(
                        "Found ${controller.properties.length}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  SizedBox(height: 20.h),

                  // Property List (Animate each one)
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.properties.isEmpty) {
                      return const Center(child: Text("No properties found", style: TextStyle(color: Colors.white)));
                    }
                    return Column(
                      children: controller.properties.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var property = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: FeatureCard(
                            imageUrl: property.propertyImage,
                            title: property.title,
                            location: property.address,
                            price: property.price,
                            beds: "—", 
                            area: "${property.area} sq.ft",
                            tag: "Featured",
                            rating: "4.5",
                            onTap: () => Get.toNamed(AppRoutes.propertyDetail, arguments: property.id),
                          )
                              .animate()
                              .fadeIn(delay: (400 + (idx * 100)).ms)
                              .slideY(begin: 0.1, end: 0),
                        );
                      }).toList(),
                    );
                  }),
                  
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
        Obx(() {
          final imageUrl = controller.locationData.value?.mainImage ?? widget.heroImage;
          return imageUrl.startsWith('http')
              ? CustomImage(
                  imageUrl: imageUrl, 
                  width: double.infinity, 
                  height: double.infinity,
                )
              : widget.heroImage.isNotEmpty 
                  ? Image.asset(widget.heroImage, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade900);
        }),
        
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
                Obx(() => Text(
                  "${controller.properties.length}+ Estates",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


