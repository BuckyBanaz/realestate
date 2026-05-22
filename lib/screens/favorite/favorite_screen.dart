import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/data/controllers/favorite_controller.dart';
import 'package:realestate/screens/home/modules/featured_properties_list.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/Routes/appRoutes.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteController controller = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Saved Properties",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshFavorites(),
        child: Obx(() {
          if (controller.isLoading.value && controller.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.favorites.isEmpty) {
            return _emptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: controller.favorites.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (ctx, i) {
              final property = controller.favorites[i];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.propertyDetail,
                      arguments: property.id,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade100
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04), 
                          blurRadius: 8, 
                          offset: const Offset(0, 4)
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Image Section
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CustomImage(
                            imageUrl: property.image,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Details Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      property.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    IconlyBold.heart,
                                    color: Colors.redAccent,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    IconlyLight.location,
                                    size: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      property.address,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹${formatFullPrice(property.price)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: primary,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      "${property.area}",
                                      style: GoogleFonts.inter(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: secondary,
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
            },
          );
        }),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.heart,
            size: 80.sp,
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 20.h),
          Text(
            "No saved properties yet",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap ♥ on listings to save your favorites.",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => Get.back(),
            child: Text(
              "Browse Listings",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
