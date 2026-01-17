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

import 'package:realestate/data/controllers/property_detail_controller.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';
import 'package:realestate/domain/app/local_storage.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailScreen({Key? key, required this.propertyId})
    : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PropertyDetailController controller = Get.put(
    PropertyDetailController(),
  );
  String _selectedAreaUnit = '';
  String _lastAreaRaw = '';

  @override
  void initState() {
    super.initState();
    controller.fetchPropertyDetails(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final property = controller.propertyDetails.value?.property;
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
                            final updatedProperty = PropertyDetailData(
                              id: property.id,
                              title: property.title,
                              slug: property.slug,
                              address: property.address,
                              price: property.price,
                              area: property.area,
                              status: property.status,
                              views: property.views,
                              category: property.category,
                              subCategory: property.subCategory,
                              attributes: property.attributes,
                              amenities: property.amenities,
                              mainImage: property.mainImage,
                              propertyImages: property.propertyImages,
                              threeSixtyView: property.threeSixtyView,
                              sitePlanImages: property.sitePlanImages,
                              isFavorite:
                                  result['is_favourite'] ??
                                  !property.isFavorite,
                            );

                            controller
                                .propertyDetails
                                .value = PropertyDetailsModel(
                              status: controller.propertyDetails.value!.status,
                              viewType:
                                  controller.propertyDetails.value!.viewType,
                              property: updatedProperty,
                              similar:
                                  controller.propertyDetails.value!.similar,
                              plotData:
                                  controller.propertyDetails.value!.plotData,
                              amenities:
                                  controller.propertyDetails.value!.amenities,
                            );

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
                              Text(
                                    property.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
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
                                    "₹${formatPrice(property.price)}",
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

                    // Details Card
                    _buildDetailsCard(context)
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 360° Virtual Tour
                    if (controller
                            .propertyDetails
                            .value
                            ?.property
                            .threeSixtyView
                            .isNotEmpty ??
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
                              .property
                              .threeSixtyView
                              .length,
                          separatorBuilder: (_, __) => SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final view = controller
                                .propertyDetails
                                .value!
                                .property
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
                    if (controller.propertyDetails.value?.plotData.isNotEmpty ??
                        false) ...[
                      Text(
                        "Choose Plots",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      SizedBox(height: 12.h),
                      PlotSelectionWidget(
                            plotData:
                                controller.propertyDetails.value?.plotData ??
                                [],
                            onPlotSelected: (plotNo, size) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Selected: $plotNo • $size"),
                                  backgroundColor: primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.1, end: 0),
                      SizedBox(height: 24.h),
                    ],

                    // Site Plan - Only show if images exist
                    if (controller
                            .propertyDetails
                            .value
                            ?.property
                            .sitePlanImages
                            .isNotEmpty ??
                        false) ...[
                      Text(
                        "Site Plan",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () {
                          final firstImage = controller
                              .propertyDetails
                              .value!
                              .property
                              .sitePlanImages
                              .first
                              .image;
                          Get.toNamed(
                            AppRoutes.sitePlan,
                            arguments: firstImage,
                          );
                        },
                        child: Hero(
                          tag: 'sitePlan',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: CustomImage(
                                imageUrl: controller
                                    .propertyDetails
                                    .value!
                                    .property
                                    .sitePlanImages
                                    .first
                                    .image,
                                width: double.infinity,
                                height: 200.h,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(),
                      SizedBox(height: 24.h),
                    ],

                    // Amenities - Only show if exist
                    if (controller
                            .propertyDetails
                            .value
                            ?.amenities
                            .isNotEmpty ??
                        false) ...[
                      _buildAmenitiesCard(),
                    ],

                    SizedBox(height: 24.h),

                    // Similar Properties
                    if (controller
                        .propertyDetails
                        .value!
                        .similar
                        .isNotEmpty) ...[
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
                          itemCount:
                              controller.propertyDetails.value!.similar.length,
                          separatorBuilder: (_, __) => SizedBox(width: 16.w),
                          itemBuilder: (context, index) {
                            final sim = controller
                                .propertyDetails
                                .value!
                                .similar[index];
                            return GestureDetector(
                              onTap: () {
                                // Reload with new property ID
                                controller.fetchPropertyDetails(sim.id).then((
                                  _,
                                ) {
                                  // Scroll to top if needed, or just let it reload
                                });
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
                                        imageUrl: sim.image,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main Background
        CustomImage(
          imageUrl: controller.propertyDetails.value?.property.mainImage ?? "",
          width: double.infinity,
          height: double.infinity,
        ),
        // Premium Dark Overlay Gradient
        Container(
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
                  "1/${(controller.propertyDetails.value?.property.propertyImages.length ?? 0) + 1} Photos",
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

  Widget _buildGalleryThumb(String path, double w, double h, Duration delay) {
    return Container(
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
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
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
                SizedBox(height: 20.h),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount:
                      (controller.propertyDetails.value?.property.attributes ??
                              [])
                          .where(
                            (attr) =>
                                attr.value != null &&
                                attr.value!.toLowerCase() != "null" &&
                                attr.value!.toLowerCase() != "n/a" &&
                                attr.value!.trim().isNotEmpty,
                          )
                          .length,
                  itemBuilder: (context, index) {
                    final validAttrs =
                        (controller
                                    .propertyDetails
                                    .value
                                    ?.property
                                    .attributes ??
                                [])
                            .where(
                              (attr) =>
                                  attr.value != null &&
                                  attr.value!.toLowerCase() != "null" &&
                                  attr.value!.toLowerCase() != "n/a" &&
                                  attr.value!.trim().isNotEmpty,
                            )
                            .toList();
                    final attr = validAttrs[index];
                    return _buildQuickSpec(
                      _getAttributeIcon(attr.attribute),
                      attr.value!,
                      attr.attribute,
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildConvertibleAreaRow(
                  controller.propertyDetails.value?.property.area ?? "N/A",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _convertArea(double value, String from, String to) {
    const toSqFt = {
      'Sq Ft': 1.0,
      'Sq Yd': 9.0,
      'Sq M': 10.7639,
      'Acre': 43560.0,
      'Grounds': 2400.0,
      'Aankadam': 72.0,
      'Rood': 10890.0,
      'Chatak': 45.0,
      'Perch': 272.25,
      'Guntha': 1089.0,
      'Ares': 1076.39,
      'Biswa (Pucca)': 1361.25,
      'Biswa (Kaccha)': 900.0,
    };
    final fromFactor = toSqFt[from] ?? 1.0;
    final toFactor = toSqFt[to] ?? 1.0;
    return (value * fromFactor) / toFactor;
  }

  String _guessUnit(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('yard') || l.contains('sq-yd') || l.contains('sq.yd')) {
      return 'Sq Yd';
    }
    if (l.contains('sq m') || l.contains('sqm')) return 'Sq M';
    if (l.contains('acre')) return 'Acre';
    if (l.contains('ground')) return 'Grounds';
    if (l.contains('aankadam') || l.contains('ankadam')) return 'Aankadam';
    if (l.contains('rood')) return 'Rood';
    if (l.contains('chatak')) return 'Chatak';
    if (l.contains('perch')) return 'Perch';
    if (l.contains('guntha')) return 'Guntha';
    if (l.contains('are')) return 'Ares';
    if (l.contains('biswa') && l.contains('kaccha')) return 'Biswa (Kaccha)';
    if (l.contains('biswa')) return 'Biswa (Pucca)';
    if (l.contains('ft') || l.contains('sqft') || l.contains('sq.ft')) {
      return 'Sq Ft';
    }
    return 'Sq Ft';
  }

  String _extractNumber(String raw) {
    final match = RegExp(r'([\d]+(\.[\d]+)?)').firstMatch(raw);
    return match?.group(1) ?? '';
  }

  String _unitLabel(String unit) {
    switch (unit) {
      case 'Sq Ft':
        return 'sq.ft.';
      case 'Sq Yd':
        return 'sq.yd.';
      case 'Sq M':
        return 'sq.m.';
      case 'Acre':
        return 'acre';
      case 'Grounds':
        return 'grounds';
      case 'Aankadam':
        return 'aankadam';
      case 'Rood':
        return 'rood';
      case 'Chatak':
        return 'chataks';
      case 'Perch':
        return 'perch';
      case 'Guntha':
        return 'guntha';
      case 'Ares':
        return 'ares';
      case 'Biswa (Pucca)':
        return 'biswa (pucca)';
      case 'Biswa (Kaccha)':
        return 'biswa (kaccha)';
      default:
        return unit.toLowerCase();
    }
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

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
                            setState(() => _selectedAreaUnit = unit);
                            Navigator.pop(context);
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : const SizedBox(width: 24),
                          title: Text(
                            _unitLabel(unit),
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
    final baseUnit = _guessUnit(rawValue);
    final baseValueStr = _extractNumber(rawValue);
    final baseValue = double.tryParse(baseValueStr);

    if (_lastAreaRaw != rawValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _lastAreaRaw = rawValue;
          _selectedAreaUnit = baseUnit;
        });
      });
    }

    final selectedUnit = _selectedAreaUnit.isEmpty
        ? baseUnit
        : _selectedAreaUnit;
    final displayValue = baseValue == null
        ? rawValue
        : _formatNumber(_convertArea(baseValue, baseUnit, selectedUnit));

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
                  "TOTAL PLOT AREA",
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
                            text: _unitLabel(selectedUnit),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _openUnitPicker(context, selectedUnit),
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
                              _unitLabel(selectedUnit),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 16.sp, color: primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: CustomImage(
              imageUrl:
                  "https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg",
              width: 80.w,
              height: 55.h,
              fit: BoxFit.cover,
            ),
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

  IconData _getAttributeIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('price')) return IconlyLight.wallet;
    if (l.contains('area')) return IconlyLight.discovery;
    if (l.contains('facing')) return Icons.explore_outlined;
    if (l.contains('dimension')) return Icons.straighten_rounded;
    if (l.contains('road')) return Icons.add_road_rounded;
    if (l.contains('bedroom') || l.contains('bhk')) return Icons.bed_outlined;
    if (l.contains('bathroom')) return Icons.bathtub_outlined;
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
      final p = controller.propertyDetails.value?.property;
      if (p == null) return const SizedBox.shrink();

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
            onPressed: () => Get.toNamed(
              AppRoutes.enquiry,
              arguments: {
                'propertyId': p.id,
                'propertyName': p.title,
                'propertyLocation': p.address,
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              elevation: 8,
              shadowColor: secondary.withOpacity(0.4),
            ),
            child: Text(
              "Submit Enquiry",
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
    final amenities = controller.propertyDetails.value?.amenities ?? [];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal Header
          Row(
            children: [
              Container(
                width: 2.5.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Amenities",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                "(${amenities.length})",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Container(height: 0.5, color: Colors.white.withOpacity(0.08)),

          SizedBox(height: 8.h),

          // Ultra Compact List
          Column(
            children: amenities.asMap().entries.map((entry) {
              final index = entry.key;
              final amenity = entry.value;
              return Column(
                children: [
                  if (index > 0) SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _getAmenityIconFromName(amenity.icon),
                            size: 14.sp,
                            color: secondary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                amenity.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (amenity.description.isNotEmpty) ...[
                                SizedBox(height: 1.h),
                                Text(
                                  amenity.description,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade700,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
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
}
