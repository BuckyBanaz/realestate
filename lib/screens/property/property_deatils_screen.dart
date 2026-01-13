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

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
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
                child: _buildCircleButton(
                  IconlyBold.heart,
                  () {},
                  isFavorite: true,
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                              "Shree Shyam Kunj Phase 2",
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(IconlyLight.location, size: 16.sp, color: primary),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    "Raipur Road, Hisar, Haryana",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        children: [
                          _buildCircleButton(Icons.share_outlined, () {}),
                          SizedBox(height: 12.h),
                          _buildCircleButton(IconlyLight.download, () {}),
                        ],
                      ).animate().fadeIn(delay: 200.ms).scale(),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Details Card
                  _buildDetailsCard(context).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  SizedBox(height: 24.h),

                  // Plot Selection
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
                    onPlotSelected: (plotNo, size) {                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selected: $plotNo • $size"),
                          backgroundColor: primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                  SizedBox(height: 24.h),

                  // Site Plan
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
                    onTap: () => Get.toNamed(AppRoutes.sitePlan, arguments: 'assets/images/map.jpg'),
                    child: Hero(
                      tag: 'sitePlan',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Image.asset(
                            'assets/images/map.jpg',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200.h,
                              color: Colors.grey.shade900,
                              child: Icon(IconlyLight.image, color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).scale(),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {bool isFavorite = false}) {
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
        Image.network(
          "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200",
          fit: BoxFit.cover,
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
                  "1/8 Photos",
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
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: path.startsWith('http')
            ? Image.network(path, fit: BoxFit.cover)
            : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900)),
      ),
    ).animate().fadeIn(delay: delay).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          // Header & Map
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Property Overview",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    _build360Badge(),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildMapPreview(),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.05), height: 1),

          // Technical Specs Grid
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildQuickSpec(IconlyLight.discovery, "30×50 ft", "Plot Size")),
                    Expanded(child: _buildQuickSpec(IconlyLight.info_square, "East", "Facing")),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(child: _buildQuickSpec(IconlyLight.location, "30 ft", "Road Width")),
                    Expanded(child: _buildQuickSpec(IconlyLight.category, "Phase 2", "Project")),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildLongSpec(IconlyLight.activity, "Park on east, main road on north", "Neighborhood"),
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
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 18.sp, color: primary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLongSpec(IconData icon, String value, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 18.sp, color: primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Container(
      width: double.infinity,
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.network(
                "https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg",
                width: 90.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Map Preview",
                  style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Get directions",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(IconlyLight.arrow_right_2, size: 16.sp, color: primary),
          ),
        ],
      ),
    );
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
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SizedBox(
        height: 56.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.enquiry, arguments: {
            'propertyName': "Shree Shyam Kunj Phase 2",
            'propertyLocation': "Raipur Road, Hisar, Haryana",
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
            elevation: 8,
            shadowColor: secondary.withOpacity(0.4),
          ),
          child: Text(
            "Submit Enquiry",
            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0);
  }
}
