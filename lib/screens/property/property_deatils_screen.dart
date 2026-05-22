import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/property/plot_selection_screen.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/screens/widgets/shimmers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:realestate/data/controllers/property_detail_controller.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/domain/app/local_storage.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailScreen({Key? key, required this.propertyId})
    : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late final PropertyDetailController controller;
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    controller = Get.put(PropertyDetailController(), tag: 'detail_${widget.propertyId}');
    controller.fetchPropertyDetails(widget.propertyId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<PropertyDetailController>(tag: 'detail_${widget.propertyId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final property = controller.propertyDetails.value;
        if (property == null) {
          return const Center(
            child: Text(
              "Property not found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ==================== PREMIUM COLLAPSIBLE HEADER ====================
            SliverAppBar(
              expandedHeight: 420.h,
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
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        property.isFavorite
                            ? IconlyBold.heart
                            : IconlyLight.heart,
                        color: property.isFavorite ? Colors.red : Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: () async {
                        try {
                          final repository = PropertyRepository();
                          final result = await repository.toggleFavorite(
                            property.id,
                          );

                          if (result['success'] == true) {
                            // Update local state by recreating the entire model
                            final updatedProperty = PropertyListItem(
                              id: property.id,
                              title: property.title,
                              slug: property.slug,
                              description: property.description,
                              categoryId: property.categoryId,
                              subcategoryId: property.subcategoryId,
                              subSubCategoryId: property.subSubCategoryId,
                              price: property.price,
                              area: property.area,
                              address: property.address,
                              city: property.city,
                              state: property.state,
                              country: property.country,
                              pincode: property.pincode,
                              propertyType: property.propertyType,
                              status: property.status,
                              createdBy: property.createdBy,
                              createdAt: property.createdAt,
                              updatedAt: property.updatedAt,
                              ownerId: property.ownerId,
                              attributes: property.attributes,
                              amenitiesList: property.amenitiesList,
                              mainImage: property.mainImage,
                              propertyImages: property.propertyImages,
                              threeSixtyView: property.threeSixtyView,
                              sitePlanImages: property.sitePlanImages,
                              isFavorite:
                                  result['is_favourite'] ??
                                  !property.isFavorite,
                              videoUrl: property.videoUrl,
                              activeHold: property.activeHold,
                            );

                            controller.propertyDetails.value = updatedProperty;

                            showCustomToast(
                              result['message'] ?? 'Favorite updated',
                              isError: false,
                            );
                          } else {
                            // Check if unauthorized (401)
                            if (result['unauthorized'] == true) {
                              showCustomToast(
                                result['message'] ??
                                    'Session expired. Please login again.',
                                isError: true,
                              );

                              // Logout and redirect to login
                              await Future.delayed(const Duration(seconds: 2));
                              final storage = LocalStorage();
                              await storage.clear();
                              Get.offAllNamed(AppRoutes.login);
                            } else {
                              showCustomToast(
                                result['message'] ??
                                    'Failed to update favorite',
                                isError: true,
                              );
                            }
                          }
                        } catch (e) {
                          showCustomToast('An error occurred', isError: true);
                        }
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: _buildHeaderGallery(),
              ),
            ),

            // ==================== CONTENT SECTION ====================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                          property.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                  ),
                                  if (property.status.toLowerCase() != 'active')
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: property.status.toLowerCase() == 'sold' 
                                          ? Colors.redAccent.withOpacity(0.1) 
                                          : Colors.orangeAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: property.status.toLowerCase() == 'sold' 
                                            ? Colors.redAccent.withOpacity(0.5) 
                                            : Colors.orangeAccent.withOpacity(0.5)
                                        ),
                                      ),
                                      child: Text(
                                        property.status.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: property.status.toLowerCase() == 'sold' 
                                            ? Colors.redAccent 
                                            : Colors.orangeAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slideX(begin: -0.1, end: 0),
                              SizedBox(height: 8.h),
                              Row(
                                    children: [
                                      Icon(
                                        IconlyLight.location,
                                        size: 16.sp,
                                        color: primary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          property.address,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .fadeIn(delay: 100.ms)
                                  .slideX(begin: -0.1, end: 0),
                              SizedBox(height: 12.h),
                              Text(
                                    "₹${formatFullPrice(property.price)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: secondary,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 150.ms)
                                  .slideX(begin: -0.1, end: 0),
                            ],
                          ),
                        ),
                        // SizedBox(width: 16.w),
                        // Column(
                        //   children: [
                        //     _buildCircleButton(Icons.share_outlined, () {}),
                        //     SizedBox(height: 12.h),
                        //     _buildCircleButton(IconlyLight.download, () {}),
                        //   ],
                        // ).animate().fadeIn(delay: 200.ms).scale(),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Hold Details Section
                    if (property.status.toLowerCase() == 'hold' && property.activeHold != null) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(IconlyLight.info_square, color: Colors.orangeAccent, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  "Hold Details",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _buildHoldInfoRow("Customer", property.activeHold!.customerName),
                            _buildHoldInfoRow("Until", property.activeHold!.holdUntil.split('T')[0]),
                            if (property.activeHold!.user != null)
                              _buildHoldInfoRow("Held By", property.activeHold!.user!.name),
                          ],
                        ),
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                      SizedBox(height: 20.h),
                    ],

                    // Details Card
                    _buildDetailsCard(context)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    // Video Tour
                    if ((controller
                                .propertyDetails
                                .value
                                ?.videoUrl
                                ?.trim()
                                .isNotEmpty ??
                            false) &&
                        controller.propertyDetails.value?.videoUrl !=
                            null) ...[
                      SizedBox(height: 24.h),
                      Text(
                        "Video Tour",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 340.ms),
                      SizedBox(height: 12.h),
                      GestureDetector(
                         onTap: () => _openVideo(
                          controller.propertyDetails.value!.videoUrl!,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 170.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 52.sp,
                                ),
                              ),
                              Positioned(
                                left: 16.w,
                                bottom: 16.h,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.video_library_rounded,
                                      color: Colors.white70,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "Watch on YouTube",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 360.ms).scale(),
                    ],

                    // 360° Virtual Tour
                    if (controller
                            .propertyDetails
                            .value
                            ?.attributes
                            .any((a) => a.attribute.toLowerCase().contains("360")) ??
                        false) ...[
                      SizedBox(height: 24.h),
                      Text(
                        "360° Virtual Tour",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 150.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller
                              .propertyDetails
                              .value!
                              .threeSixtyView
                              .length,
                          separatorBuilder: (_, __) => SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final view = controller
                                .propertyDetails
                                .value!
                                .threeSixtyView[index];
                            return Container(
                              width: 260.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24.r),
                                    child: CustomImage(
                                      imageUrl: view.image,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.r),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.threesixty,
                                        color: Colors.white,
                                        size: 28.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // Plot Selection
                    Obx(() {
                      final p = controller.propertyDetails.value;
                      final categoryName = p?.category?.name ?? '';
                      final isPlotCategory = categoryName.toLowerCase().contains("plot");
                      
                      if (!isPlotCategory) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choose Plots",
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                          SizedBox(height: 12.h),
                          if (controller.isPlotsLoading.value)
                            const PlotsGridShimmer()
                          else if (controller.availablePlots.length > 1)
                            PlotSelectionWidget(
                              plotData: controller.availablePlots,
                              selectedPropertyId: controller.selectedPropertyId.value,
                              onPlotSelected: (plot) {
                                controller.onPlotSelected(plot);
                              },
                            ).animate().fadeIn(delay: Duration(milliseconds: 500)).slideY(begin: 0.1, end: 0)
                          else
                            const SizedBox.shrink(),
                          SizedBox(height: 24.h),
                        ],
                      );
                    }),

                    // Site Plan - Only show if images exist
                    if (controller
                            .propertyDetails
                            .value
                            ?.attributes
                            .any((a) => a.attribute.toLowerCase().contains("map") || a.attribute.toLowerCase().contains("plan")) ??
                        false) ...[
                      Text(
                        "Map Images",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 140.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: (controller.propertyDetails.value?.sitePlanImages.isNotEmpty ?? false) 
                              ? controller.propertyDetails.value!.sitePlanImages.length 
                              : 1,
                          separatorBuilder: (_, __) => SizedBox(width: 14.w),
                          itemBuilder: (context, index) {
                            final p = controller.propertyDetails.value!;
                            final images = p.sitePlanImages.isNotEmpty 
                                ? p.sitePlanImages.map((img) => img.image).toList()
                                : [p.mainImageUrl ?? p.mainImage ?? ""];
                            final image = images[index];
                            return GestureDetector(
                              onTap: () => Get.toNamed(
                                AppRoutes.sitePlan,
                                arguments: image,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18.r),
                                child: Container(
                                  width: 200.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: CustomImage(
                                    imageUrl: image,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(),
                      SizedBox(height: 24.h),
                    ],

                    // Amenities - Only show if exist
                    if ((controller
                            .propertyDetails
                            .value
                            ?.amenitiesList.isNotEmpty) ?? false) ...[
                      _buildAmenitiesCard(),
                    ],

                    SizedBox(height: 24.h),

                    // Similar Properties
                    if (controller.availablePlots.length > 1) ...[
                      Text(
                        "Similar Properties",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 750.ms),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 180.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.availablePlots.length,
                          separatorBuilder: (_, __) => SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final sim = controller.availablePlots[index];
                            return GestureDetector(
                              onTap: () {
                                // Reload with new property ID
                                  controller.fetchPropertyDetails(sim.id);
                              },
                              child: Container(
                                width: 160.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                      child: CustomImage(
                                        imageUrl: sim.mainImageUrl ?? sim.mainImage ?? "",
                                        height: 100.h,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sim.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            sim.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHoldInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback onTap, {
    bool isFavorite = false,
  }) {
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
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isFavorite ? Colors.redAccent : Colors.white,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderGallery() {
    final property = controller.propertyDetails.value;
    if (property == null) return const SizedBox.shrink();

    final List<String> allImages = [];
    if (property.mainImage != null && property.mainImage!.isNotEmpty) {
      allImages.add(property.mainImage!);
    }
    if (property.propertyImages.isNotEmpty) {
      allImages.addAll(property.propertyImages.map((e) => e.image).toList());
    }

    if (allImages.isEmpty) {
      return Container(color: Colors.grey.shade900);
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Main Background
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullScreenImage(allImages, index),
                  child: CustomImage(
                    imageUrl: allImages[index],
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
            // Premium Dark Overlay Gradient
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Theme.of(Get.context!).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            // Indicators
            if (allImages.length > 1)
              Positioned(
                bottom: 80.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentImageIndex == index ? 20.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? primary
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            // Gallery Counter / Detail Chip
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
                    Icon(IconlyLight.image, size: 16.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      "${_currentImageIndex + 1}/${allImages.length} Photos",
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
    );
  }

  Widget _buildGalleryThumb(String path, double w, double h, Duration delay) {
    return GestureDetector(
      onTap: () => _showFullScreenImage([path], 0),
      child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: path.startsWith('http')
                ? CustomImage(imageUrl: path)
                : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade900),
                  ),
          ),
        )
            .animate()
            .fadeIn(delay: delay)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header & Map Section
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Property Overview",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    _build360Badge(),
                  ],
                ),
                if (controller.propertyDetails.value?.latitude != null && 
                    controller.propertyDetails.value?.longitude != null)
                  _buildMapPreview(),
              ],
            ),
          ),

          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            color: Colors.white.withOpacity(0.05),
          ),

          // Tech Specs Section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Builder(builder: (_) {
                  final attrs = (controller.propertyDetails.value?.attributes ?? []).where(
                    (attr) =>
                        attr.value != null &&
                        attr.value!.toLowerCase() != "null" &&
                        attr.value!.toLowerCase() != "n/a" &&
                        attr.value!.trim().isNotEmpty,
                  ).toList();
                  if (attrs.isEmpty) return const SizedBox.shrink();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: attrs.length,
                    itemBuilder: (context, index) {
                      final attr = attrs[index];
                      return _buildQuickSpec(
                        _getAttributeIcon(attr.attribute),
                        attr.value!,
                        attr.attribute,
                      );
                    },
                  );
                }),
                SizedBox(height: 16.h),
                _buildConvertibleAreaRow(
                  controller.propertyDetails.value?.area ?? "N/A",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Manual unit conversion logic removed (now in controller)

  void _openUnitPicker(BuildContext context, String currentUnit) {
    const units = [
      'Sq Ft',
      'Sq Yd',
      'Sq M',
      'Grounds',
      'Aankadam',
      'Rood',
      'Chatak',
      'Perch',
      'Guntha',
      'Ares',
      'Biswa (Pucca)',
      'Biswa (Kaccha)',
      'Acre',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Select Area Unit",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Flexible(
                    child: ListView.separated(
                      itemCount: units.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      itemBuilder: (context, index) {
                        final unit = units[index];
                        final selected = unit == currentUnit;
                        return ListTile(
                          onTap: () {
                            controller.updateAreaUnit(unit);
                            Navigator.pop(context);
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : const SizedBox(width: 24),
                          title: Text(
                            controller.unitLabel(unit),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConvertibleAreaRow(String rawValue) {
    return Obx(() {
      final displayValue = controller.getDisplayArea(rawValue);
      final currentUnit = controller.selectedAreaUnit.value;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(IconlyLight.discovery, size: 20.sp, color: primary),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL ${(controller.propertyDetails.value?.propertyType ?? 'PROPERTY').toUpperCase()} AREA",
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(text: displayValue),
                            const TextSpan(text: " "),
                            TextSpan(
                              text: controller.unitLabel(currentUnit),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _openUnitPicker(context, currentUnit),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.unitLabel(currentUnit),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ],
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
      );
    });
  }

  Widget _build360Badge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.threesixty, size: 14.sp, color: primary),
          SizedBox(width: 4.w),
          Text(
            "360°",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSpec(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 15.sp, color: primary),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 55.h,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(IconlyBold.location, color: primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Property Location",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Get directions to site",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(IconlyLight.arrow_right_2, size: 16.sp, color: primary),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      showCustomToast("Invalid video URL", isError: true);
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      showCustomToast("Unable to open video", isError: true);
    }
  }

  IconData _getAttributeIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('price') || l.contains('rate')) return IconlyLight.wallet;
    if (l.contains('area') || l.contains('size')) return IconlyLight.discovery;
    if (l.contains('facing')) return Icons.explore_outlined;
    if (l.contains('dimension') || l.contains('length')) return Icons.straighten_rounded;
    if (l.contains('road')) return Icons.add_road_rounded;
    if (l.contains('bedroom') || l.contains('bhk')) return Icons.bed_outlined;
    if (l.contains('bathroom')) return Icons.bathtub_outlined;
    if (l.contains('corner')) return Icons.grid_view_rounded;
    if (l.contains('connectivity')) return Icons.connect_without_contact_rounded;
    return IconlyLight.info_square;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final p = controller.propertyDetails.value;
      if (p == null) return const SizedBox.shrink();

      final status = p.status.toLowerCase();
      final isUnavailable = status == 'sold' || status == 'hold';
      
      String buttonText = "Submit Enquiry";
      Color buttonColor = secondary;
      
      if (status == 'sold') {
        buttonText = "Sold Out";
        buttonColor = Colors.grey.shade700;
      } else if (status == 'hold') {
        buttonText = "On Hold";
        buttonColor = Colors.grey.shade700;
      }

      return Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: SizedBox(
          height: 56.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isUnavailable 
              ? () {
                  showCustomToast(
                    "Property already on hold or sold. Please choose another plot from the list above.",
                    isError: true,
                  );
                }
              : () => Get.toNamed(
                  AppRoutes.enquiry,
                  arguments: {
                    'propertyId': p.id,
                    'propertyName': p.title,
                    'propertyLocation': p.address,
                  },
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              elevation: isUnavailable ? 0 : 8,
              shadowColor: isUnavailable ? Colors.transparent : secondary.withOpacity(0.4),
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0);
    });
  }

  Widget _buildAmenitiesCard() {
    final amenities = controller.propertyDetails.value?.amenitiesList ?? [];
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18.sp, color: secondary),
              SizedBox(width: 8.w),
              Text(
                "Amenities",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIconFromName(amenity.icon),
                      size: 14.sp,
                      color: secondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      amenity.title,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 300)).slideY(begin: 0.1, end: 0);
  }

  IconData _getAmenityIconFromName(String iconName) {
    // Font Awesome icon names to Material icons mapping
    switch (iconName.toLowerCase()) {
      case 'fa-person-swimming':
      case 'swimming':
        return Icons.pool_rounded;
      case 'fa-tree':
      case 'garden':
        return Icons.park_rounded;
      case 'fa-shield-halved':
      case 'security':
        return Icons.security_rounded;
      case 'fa-water':
      case 'water':
        return Icons.water_drop_rounded;
      case 'fa-bolt':
      case 'power':
        return Icons.electric_bolt_rounded;
      case 'fa-camera':
      case 'cctv':
        return Icons.videocam_rounded;
      case 'fa-car':
      case 'parking':
        return Icons.directions_car_rounded;
      case 'fa-dumbbell':
      case 'gym':
        return Icons.fitness_center_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  void _showFullScreenImage(List<String> images, int initialIndex) {
    if (images.isEmpty) return;

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'fs_${images[index]}_$index',
                      child: CustomImage(
                        imageUrl: images[index],
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 10.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: MediaQuery.of(Get.context!).padding.bottom + 20.h,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Swipe to see more",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    );
  }
}
