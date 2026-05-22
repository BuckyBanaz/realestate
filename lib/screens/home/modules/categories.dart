import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/controllers/home_controller.dart';
import 'package:realestate/data/models/category_filter_model.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final selectedCat = controller.selectedCategory.value;
      final selectedSubCat = controller.selectedSubCategory.value;
      final selectedSubSubCat = controller.selectedSubSubCategory.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tier 1: Main Categories
          _buildMainCategoryHeader("Categories"),
          SizedBox(height: 12.h),
          if (controller.categories.isNotEmpty)
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: controller.categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _buildMainCategoryChip(
                    controller: controller,
                    category: category,
                    selectedCategory: selectedCat,
                  );
                },
              ),
            ),

          // 2. Tier 2: Sub Categories (Animated appearance)
          if (controller.subCategories.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildSubHeader("Sub Categories"),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 38.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: controller.subCategories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final subCat = controller.subCategories[index];
                      return _buildSubCategoryChip(
                        controller: controller,
                        category: subCat,
                        isSubSub: false,
                        selectedSubCategory: selectedSubCat,
                        selectedSubSubCategory: selectedSubSubCat,
                      );
                    },
                  ),
                ).animate().fadeIn().slideX(begin: 0.1, end: 0),
              ],
            ),

          // 3. Tier 3: Sub-Sub Categories
          if (controller.subSubCategories.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildSubHeader("PROJECTS"),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 32.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: controller.subSubCategories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final subSubCat = controller.subSubCategories[index];
                      return _buildSubCategoryChip(
                        controller: controller,
                        category: subSubCat,
                        isSubSub: true,
                        selectedSubCategory: selectedSubCat,
                        selectedSubSubCategory: selectedSubSubCat,
                      );
                    },
                  ),
                ).animate().fadeIn().slideX(begin: 0.1, end: 0),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildMainCategoryHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMainCategoryChip({
    required HomeController controller,
    required CategoryFilter category,
    required CategoryFilter? selectedCategory,
  }) {
    final isActive = selectedCategory?.id == category.id;

    return GestureDetector(
      onTap: () => controller.onCategorySelected(isActive ? null : category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isActive ? secondary : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isActive ? secondary : Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: secondary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForCategory(category.name),
                color: isActive ? Colors.white : Colors.grey.shade500,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                category.name,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip({
    required HomeController controller,
    required CategoryFilter category,
    required bool isSubSub,
    required CategoryFilter? selectedSubCategory,
    required CategoryFilter? selectedSubSubCategory,
  }) {
    final bool isActive = isSubSub 
        ? selectedSubSubCategory?.id == category.id
        : selectedSubCategory?.id == category.id;

    return GestureDetector(
      onTap: () => isSubSub 
          ? controller.onSubSubCategorySelected(isActive ? null : category)
          : controller.onSubCategorySelected(isActive ? null : category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isActive ? secondary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isActive ? secondary : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Icon(Icons.check, color: secondary, size: 14.sp),
                ),
              Text(
                category.name,
                style: TextStyle(
                  color: isActive ? secondary : Colors.grey.shade400,
                  fontSize: isSubSub ? 11.sp : 12.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('plot')) return Icons.grid_view_rounded;
    if (n.contains('house') || n.contains('villa')) return IconlyBold.home;
    if (n.contains('apartment') || n.contains('flat')) return Icons.apartment_rounded;
    if (n.contains('commercial') || n.contains('office')) return Icons.business_rounded;
    if (n.contains('land')) return Icons.landscape_rounded;
    if (n.contains('farm')) return Icons.agriculture_rounded;
    return Icons.category_rounded;
  }
}
