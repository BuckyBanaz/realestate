import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/home_controller.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onMicTap;

  const SearchTextField({
    Key? key,
    this.controller,
    this.onChanged,
    this.onMicTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = max(50.h, 56.0); // ensure a reasonable min height
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.search),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(IconlyLight.search, color: Colors.white, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: false,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: "Search House, Apartment, etc.",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                final homeController = Get.find<HomeController>();
                _showFilterBottomSheet(context, homeController);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(IconlyLight.filter, color: primary, size: 20.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      const _FilterBottomSheetContent(),
      isScrollControlled: true,
      ignoreSafeArea: false,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FilterBottomSheetContent extends GetView<HomeController> {
  const _FilterBottomSheetContent();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212), // Darker, more premium background
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Grab Handle
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.h),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filters",
                            style: GoogleFonts.outfit(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.clearAllFilters(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                "Clear All",
                                style: GoogleFonts.inter(
                                  color: Colors.redAccent,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      
                      // Category Selection
                      _buildSectionHeader("Category", "Main property type"),
                      SizedBox(height: 12.h),
                      Obx(() => Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: controller.categories.map((cat) => _buildModernChip(
                          cat.name,
                          controller.selectedCategory.value?.id == cat.id,
                          () => controller.onCategorySelected(controller.selectedCategory.value?.id == cat.id ? null : cat),
                        )).toList(),
                      )),
                      SizedBox(height: 24.h),

                      // Sub Category Selection
                      Obx(() => controller.subCategories.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Sub Category", "Refine your search"),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: controller.subCategories.map((sub) => _buildModernChip(
                              sub.name,
                              controller.selectedSubCategory.value?.id == sub.id,
                              () => controller.onSubCategorySelected(controller.selectedSubCategory.value?.id == sub.id ? null : sub),
                            )).toList(),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ) : const SizedBox.shrink()),

                      // Sub-Sub Category (Projects) Selection
                      Obx(() => controller.subSubCategories.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Project / Area", "Select specific location"),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: controller.subSubCategories.map((ssc) => _buildModernChip(
                              ssc.name,
                              controller.selectedSubSubCategory.value?.id == ssc.id,
                              () => controller.onSubSubCategorySelected(controller.selectedSubSubCategory.value?.id == ssc.id ? null : ssc),
                            )).toList(),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ) : const SizedBox.shrink()),

                      // Facing Section
                      _buildSectionHeader(
                        "Facing Orientation",
                        "Select plot facing",
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children:
                              [
                                    'North',
                                    'North-East',
                                    'East',
                                    'South-East',
                                    'South',
                                    'South-West',
                                    'West',
                                    'North-West',
                                  ]
                                  .map(
                                    (f) => _buildModernChip(
                                      f,
                                      controller.selectedFacing.value == f,
                                      () => controller.selectedFacing.value =
                                          (controller.selectedFacing.value == f
                                          ? ""
                                          : f),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Corner Plot Section
                      _buildSectionHeader(
                        "Property Attributes",
                        "Special features",
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => _buildModernToggleCard(
                          "Corner Plot Only",
                          "Show only corner properties",
                          IconlyLight.discovery,
                          controller.isCornerPlot.value,
                          () => controller.isCornerPlot.toggle(),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Minimum Area Section
                      _buildSectionHeader(
                        "Minimum Area",
                        "Filter by plot size (sqyd)",
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [100, 200, 300, 400, 500].map((a) {
                            final label = "$a+ sqyd";
                            return _buildModernChip(
                              label,
                              controller.selectedMinArea.value == a,
                              () => controller.selectedMinArea.value =
                                  (controller.selectedMinArea.value == a
                                  ? 0
                                  : a),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Price Range Section
                      _buildSectionHeader("Price Range", "Set your budget"),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernPriceField(
                              "Min Price",
                              controller.minPriceController,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildModernPriceField(
                              "Max Price",
                              controller.maxPriceController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      // Apply Button
                      Container(
                        width: double.infinity,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          gradient: LinearGradient(
                            colors: [
                              secondary,
                              secondary.withOpacity(0.8),
                            ], // Theme Gold Gradient
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: secondary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            controller.applyAdvancedFilters();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            "Apply Filters",
                            style: GoogleFonts.outfit(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildModernChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? primary : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernToggleCard(
    String title,
    String subtitle,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? primary : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isActive
                    ? primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? primary : Colors.white.withOpacity(0.4),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Switch.adaptive(
              value: isActive,
              onChanged: (_) => onTap(),
              activeColor: primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPriceField(
    String hint,
    TextEditingController textController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.currency_rupee, color: primary, size: 16.sp),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        ),
      ),
    );
  }
}
