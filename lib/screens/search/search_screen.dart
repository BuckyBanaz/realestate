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
                  // SizedBox(width: 12.w),
                  // Container(
                  //   height: 52.h,
                  //   width: 52.h,
                  //   decoration: BoxDecoration(
                  //     color: secondary,
                  //     borderRadius: BorderRadius.circular(16.r),
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(IconlyLight.filter, color: Colors.white),
                  //     onPressed: () {
                  //       // TODO: Open Filter Modal
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),

            // Category Filters (Horizontal)
            SizedBox(
              height: 55.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  _buildCategoryChip(controller, "All"),
                  SizedBox(width: 10.w),
                  _buildCategoryChip(controller, "Residential"),
                  SizedBox(width: 10.w),
                  _buildCategoryChip(controller, "Commercial"),
                  SizedBox(width: 10.w),
                  _buildCategoryChip(controller, "Plot"),
                  SizedBox(width: 10.w),
                  _buildCategoryChip(controller, "Agricultural"),
                  SizedBox(width: 10.w),
                  _buildCategoryChip(controller, "Farmhouse"),
                ],
              ),
            ),

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

                return CustomScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Find results in your area",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "${controller.searchResults.length} Results",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: secondary,
                                fontWeight: FontWeight.w600,
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
                          final property = controller.searchResults[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: PropertyCard(property: property),
                          );
                        }, childCount: controller.searchResults.length),
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

  Widget _buildCategoryChip(
    PropertySearchController controller,
    String category,
  ) {
    return Obx(() {
      final isActive = controller.selectedCategory.value == category;
      return GestureDetector(
        onTap: () => controller.selectCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? secondary : cardColor,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: isActive ? secondary : Colors.white.withOpacity(0.05),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              category,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : Colors.grey.shade400,
                fontSize: 13.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
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
                Positioned(
                  top: 12.h,
                  right: 12.w,
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
                      "₹${formatPrice(property.price)}",
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
