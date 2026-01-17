import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:realestate/constant/app_colors.dart';

class BaseShimmer extends StatelessWidget {
  final Widget child;
  const BaseShimmer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E), // Dark card color
      highlightColor: const Color(0xFF2C2C2C), // Slightly lighter for shimmer
      child: child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const ShimmerContainer({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 12,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ---------------- Featured Properties Shimmer ----------------
class FeaturedShimmer extends StatelessWidget {
  const FeaturedShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320.h,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return BaseShimmer(
            child: Container(
              width: 300.w,
              height: 320.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(36.r),
              ),
              child: Stack(
                children: [
                  // Mimic Content Layout
                  Positioned(
                    bottom: 24.h,
                    left: 24.w,
                    right: 24.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerContainer(width: 150.w, height: 24.h, radius: 4),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                             ShimmerContainer(width: 80.w, height: 30.h, radius: 12),
                             SizedBox(width: 10.w),
                             ShimmerContainer(width: 80.w, height: 30.h, radius: 12),
                             Spacer(),
                             ShimmerContainer(width: 60.w, height: 30.h, radius: 12),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        ShimmerContainer(width: 120.w, height: 36.h, radius: 24),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Top Locations Shimmer ----------------
class TopLocationsShimmer extends StatelessWidget {
  const TopLocationsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          return BaseShimmer(
            child: Container(
              width: 300.w,
              height: 140.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  ShimmerContainer(width: 110.w, height: 116.h, radius: 20.r),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerContainer(width: 60.w, height: 16.h, radius: 4),
                        SizedBox(height: 10.h),
                        ShimmerContainer(width: 120.w, height: 20.h, radius: 4),
                        SizedBox(height: 4.h),
                        ShimmerContainer(width: 80.w, height: 14.h, radius: 4),
                        const Spacer(),
                        ShimmerContainer(width: 80.w, height: 24.h, radius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Recommended Properties Shimmer ----------------
class RecommendedShimmer extends StatelessWidget {
  const RecommendedShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.h,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return BaseShimmer(
            child: Container(
              width: 220.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: ShimmerContainer(width: double.infinity, height: 140.h, radius: 20.r),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerContainer(width: 150.w, height: 16.h, radius: 4),
                        SizedBox(height: 4.h),
                        ShimmerContainer(width: 100.w, height: 12.h, radius: 4),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerContainer(width: 60.w, height: 16.h, radius: 4),
                            ShimmerContainer(width: 60.w, height: 14.h, radius: 4),
                          ],
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
    );
  }
}

// ---------------- News Shimmer ----------------
class NewsShimmer extends StatelessWidget {
  const NewsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h, 
      child: ListView.separated(
         padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          return BaseShimmer(
            child: Container(
              width: 260.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   ShimmerContainer(width: double.infinity, height: 140.h, radius: 16.r),
                   Padding(
                     padding: EdgeInsets.all(14.w),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         ShimmerContainer(width: 180.w, height: 15.h, radius: 4),
                         SizedBox(height: 8.h),
                         ShimmerContainer(width: double.infinity, height: 11.h, radius: 4),
                         SizedBox(height: 4.h),
                         ShimmerContainer(width: 150.w, height: 11.h, radius: 4),
                         SizedBox(height: 20.h),
                         ShimmerContainer(width: 80.w, height: 14.h, radius: 4),
                       ],
                     ),
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Categories Shimmer ----------------
class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return BaseShimmer(
            child: ShimmerContainer(
              width: 80.w + (index * 10),
              height: 38.h,
              radius: 10.r,
            ),
          );
        },
      ),
    );
  }
}
