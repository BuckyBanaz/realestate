import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/controllers/search_controller.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/data/models/category_filter_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertySearchController());

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          'Search Properties',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: (val) => controller.updateSearchQuery(val),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText: 'Search city, title, address...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(
                            IconlyLight.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(() {
                    final hasFilter =
                        controller.minPrice.value != null ||
                        controller.maxPrice.value != null;
                    return Container(
                      height: 52.h,
                      width: 52.h,
                      decoration: BoxDecoration(
                        color: hasFilter ? secondary : cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          IconlyLight.filter,
                          color: hasFilter ? Colors.white : Colors.grey,
                        ),
                        onPressed: () => _openFilterSheet(context, controller),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Hierarchical Filters
            Obx(() {
              final hasFilters = controller.selectedCategory.value != null || 
                                controller.selectedSubCategory.value != null || 
                                controller.selectedSubSubCategory.value != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tier 1: Main Categories
                  if (controller.categories.isNotEmpty)
                    SizedBox(
                      height: 40.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          return _buildMainCategoryChip(controller, category);
                        },
                      ),
                    ),

                  // 2. Tier 2: Sub Categories
                  if (controller.subCategories.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 36.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: controller.subCategories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              final subCat = controller.subCategories[index];
                              return _buildSubCategoryChip(controller, subCat, isSubSub: false);
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
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 32.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: controller.subSubCategories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              final subSubCat = controller.subSubCategories[index];
                              return _buildSubCategoryChip(controller, subSubCat, isSubSub: true);
                            },
                          ),
                        ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                      ],
                    ),

                  // Clear Filters & Breadcrumb Bar
                  if (hasFilters) 
                    _buildFilterBreadcrumb(controller),
                ],
              );
            }),

            // Results Section
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.searchResults.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredResults = controller.searchResults;

                if (filteredResults.isEmpty) {
                  return _buildEmptyState();
                }

                return CustomScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                "${filteredResults.length} Properties",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Find results in your area",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final property = filteredResults[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: PropertyCard(property: property),
                          );
                        }, childCount: filteredResults.length),
                      ),
                    ),
                    if (controller.isMoreLoading.value)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    if (!controller.hasNextPage &&
                        controller.searchResults.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              "You've reached the end of results",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildCategories(List<PropertyListItem> items) {
    final result = <String>["All"];
    final seen = <String>{};
    for (final item in items) {
      final type = item.propertyType.trim();
      if (type.isEmpty) continue;
      final key = type.toLowerCase();
      if (seen.add(key)) {
        result.add(type);
      }
    }
    return result;
  }

  void _openFilterSheet(
    BuildContext context,
    PropertySearchController controller,
  ) {
    final minController = TextEditingController(
      text: controller.minPrice.value?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: controller.maxPrice.value?.toString() ?? '',
    );

    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Advanced Filters",
                              style: GoogleFonts.outfit(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.clearFilters();
                                minController.clear();
                                maxController.clear();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

                        // 1. Hierarchical Categories
                        _buildSectionHeader("Category", "Main property type"),
                        SizedBox(height: 12.h),
                        Obx(() => Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: controller.categories.map((cat) => _buildModernFilterChip(
                            cat.name,
                            controller.selectedCategory.value?.id == cat.id,
                            () => controller.onCategorySelected(controller.selectedCategory.value?.id == cat.id ? null : cat),
                          )).toList(),
                        )),
                        SizedBox(height: 24.h),

                        Obx(() => controller.subCategories.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Sub Category", "Refine your search"),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children: controller.subCategories.map((sub) => _buildModernFilterChip(
                                sub.name,
                                controller.selectedSubCategory.value?.id == sub.id,
                                () => controller.onSubCategorySelected(controller.selectedSubCategory.value?.id == sub.id ? null : sub),
                              )).toList(),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ) : const SizedBox.shrink()),

                        Obx(() => controller.subSubCategories.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Project / Area", "Select specific location"),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.h,
                              children: controller.subSubCategories.map((ssc) => _buildModernFilterChip(
                                ssc.name,
                                controller.selectedSubSubCategory.value?.id == ssc.id,
                                () => controller.onSubSubCategorySelected(controller.selectedSubSubCategory.value?.id == ssc.id ? null : ssc),
                              )).toList(),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ) : const SizedBox.shrink()),

                        // 2. Facing
                        _buildSectionHeader("Facing", "Plot orientation"),
                        SizedBox(height: 12.h),
                        Obx(() => Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: ['North', 'East', 'South', 'West', 'North-East', 'South-East', 'South-West', 'North-West'].map((f) => _buildModernFilterChip(
                            f,
                            controller.selectedFacing.value == f,
                            () => controller.selectedFacing.value = controller.selectedFacing.value == f ? "" : f,
                          )).toList(),
                        )),
                        SizedBox(height: 24.h),

                        // 3. Corner Plot
                        _buildSectionHeader("Attributes", "Special features"),
                        SizedBox(height: 12.h),
                        Obx(() => _buildModernToggleCard(
                          "Corner Plot Only",
                          "Show only corner properties",
                          IconlyLight.discovery,
                          controller.isCornerPlot.value,
                          () => controller.isCornerPlot.toggle(),
                        )),
                        SizedBox(height: 24.h),

                        // 4. Price Range
                        _buildSectionHeader("Price Range", "Set your budget"),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(child: _buildModernPriceField("Min Price", (val) => minController.text = val, minController)),
                            SizedBox(width: 16.w),
                            Expanded(child: _buildModernPriceField("Max Price", (val) => maxController.text = val, maxController)),
                          ],
                        ),
                        SizedBox(height: 40.h),

                        // Apply Button
                        Container(
                          width: double.infinity,
                          height: 60.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: LinearGradient(colors: [secondary, secondary.withOpacity(0.8)]),
                            boxShadow: [
                              BoxShadow(color: secondary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              controller.minPrice.value = double.tryParse(minController.text);
                              controller.maxPrice.value = double.tryParse(maxController.text);
                              controller.applyFilters();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                            ),
                            child: Text(
                              "Apply Filters",
                              style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        SizedBox(height: 4.h),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildModernFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? secondary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? secondary : Colors.white.withOpacity(0.08), width: 1.5),
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

  Widget _buildModernToggleCard(String title, String subtitle, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isActive ? secondary : Colors.white.withOpacity(0.08), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: isActive ? secondary.withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, color: isActive ? secondary : Colors.white.withOpacity(0.4), size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white.withOpacity(0.4))),
              ],
            ),
            const Spacer(),
            Switch.adaptive(value: isActive, onChanged: (_) => onTap(), activeColor: secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPriceField(String hint, Function(String) onChanged, TextEditingController textController) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.currency_rupee, color: secondary, size: 16.sp),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        ),
      ),
    );
  }

  Widget _buildMainCategoryChip(
    PropertySearchController controller,
    CategoryFilter category,
  ) {
    return Obx(() {
      final isActive = controller.selectedCategory.value?.id == category.id;
      return GestureDetector(
        onTap: () => controller.onCategorySelected(isActive ? null : category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isActive ? secondary.withOpacity(0.15) : cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isActive ? secondary : Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: secondary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForCategory(category.name),
                  color: isActive ? Colors.white : Colors.grey.shade500,
                  size: 14.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  category.name,
                  style: GoogleFonts.inter(
                    color: isActive ? Colors.white : Colors.grey.shade400,
                    fontSize: 13.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (category.children.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isActive ? Colors.white70 : Colors.grey.shade600,
                      size: 16.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubCategoryChip(PropertySearchController controller, CategoryFilter category, {required bool isSubSub}) {
    final bool isActive = isSubSub 
        ? controller.selectedSubSubCategory.value?.id == category.id
        : controller.selectedSubCategory.value?.id == category.id;

    return GestureDetector(
      onTap: () => isSubSub 
          ? controller.onSubSubCategorySelected(isActive ? null : category)
          : controller.onSubCategorySelected(isActive ? null : category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isActive ? secondary.withOpacity(0.15) : cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive ? secondary : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.name,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (!isSubSub && category.children.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isActive ? Colors.white70 : Colors.grey.shade600,
                    size: 14.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBreadcrumb(PropertySearchController controller) {
    String path = "";
    if (controller.selectedCategory.value != null) {
      path += controller.selectedCategory.value!.name;
    }
    if (controller.selectedSubCategory.value != null) {
      path += " > ${controller.selectedSubCategory.value!.name}";
    }
    if (controller.selectedSubSubCategory.value != null) {
      path += " > ${controller.selectedSubSubCategory.value!.name}";
    }
    if (controller.selectedFacing.value.isNotEmpty) {
      path += " | ${controller.selectedFacing.value}";
    }
    if (controller.isCornerPlot.value) {
      path += " | Corner Plot";
    }
    if (controller.selectedMinArea.value > 0) {
      path += " | ${controller.selectedMinArea.value}+ sqyd";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: InkWell(
            onTap: () => controller.clearFilters(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: Colors.redAccent.withOpacity(0.7), size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  "Clear all filters",
                  style: TextStyle(
                    color: Colors.redAccent.withOpacity(0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(IconlyBold.filter, color: secondary, size: 14.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.clearFilters(),
                child: Icon(Icons.close, color: Colors.grey, size: 14.sp),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
            child: Icon(
              IconlyLight.search,
              color: Colors.grey.shade700,
              size: 45.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "No properties found",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Try keyword or different filters",
            style: TextStyle(color: Colors.grey, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final PropertyListItem property;
  PropertyCard({required this.property, super.key});

  @override
  Widget build(BuildContext context) {
    final status = property.status.toLowerCase();
    Color statusColor = const Color(0xFF00C853); // Green for active/default
    String statusText = 'ACTIVE';

    if (status == 'sold') {
      statusColor = Colors.redAccent;
      statusText = 'SOLD';
    } else if (status == 'hold') {
      statusColor = Colors.orangeAccent;
      statusText = 'HOLD';
    } else if (status.isNotEmpty) {
      statusText = status.toUpperCase();
    }

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.propertyDetail, arguments: property.id),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: CustomImage(
                    imageUrl: property.mainImageUrl ?? property.mainImage ?? "",
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallbackAsset: 'assets/images/download.jpg',
                  ),
                ),
                // Status Badge (Top Right)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Property Type Badge (Top Left - only if not empty)
                if (property.propertyType.trim().isNotEmpty)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        property.propertyType,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "₹${formatFullPrice(property.price)}",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details Section
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        IconlyLight.location,
                        size: 14.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          property.address,
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      if (property.bedrooms != null) ...[
                        _buildInfoIcon(
                          IconlyBold.show,
                          "${property.bedrooms} Beds",
                        ),
                        SizedBox(width: 16.w),
                      ],
                      _buildInfoIcon(
                        IconlyBold.category,
                        "${property.area} Sq.Ft",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: secondary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
        ),
      ],
    );
  }
}
