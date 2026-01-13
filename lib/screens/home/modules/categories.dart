import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';

/// Simple data holder for a category — only title used for now.
class CategoryItem {
  final String title;
  final String subtitle; // optional text like "in Hisar"
  final String? iconUrl; // optional network image url
  final String? assetIcon; // optional local asset path (SVG/PNG)

  CategoryItem({
    required this.title,
    this.subtitle = '',
    this.iconUrl,
    this.assetIcon,
  });
}

/// Main Categories widget (horizontal list)
class Categories extends StatelessWidget {
  final List<CategoryItem>? categories;
  final void Function(CategoryItem)? onCategoryTap;

  const Categories({Key? key, this.categories, this.onCategoryTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // fallback default list (NO ERROR)
    final list =
        categories ??
        [
          CategoryItem(
            title: "FLATS / HOUSING",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/flats_housing.svg",
          ),
          CategoryItem(
            title: "TOWNSHIPS",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/townships.svg",
          ),
          CategoryItem(
            title: "FARM HOUSES",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/farm_houses.svg",
          ),
          CategoryItem(
            title: "SOCIETIES",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/societies.svg",
          ),
          CategoryItem(
            title: "PLOTS",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/plots.svg",
          ),
          CategoryItem(
            title: "AGRI LAND",
            subtitle: "in Hisar",
            assetIcon: "assets/svg/agri_land.svg",
          ),
        ];

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: list.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (ctx, i) {
          final item = list[i];
          return PropertyCategoryCard(
            title: item.title,
            subtitle: item.subtitle,
            iconUrl: item.iconUrl,
            assetIcon: item.assetIcon,
            // onTap: () => onCategoryTap?.call(item)
              onTap: () => Get.toNamed(AppRoutes.subCategory),
          );
        },
      ),
    );
  }
}

/// Single card UI (matches the screenshot: white rounded card, icon left, text right)
class PropertyCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconUrl; // optional network icon
  final String? assetIcon; // optional local asset path (SVG or raster)
  final VoidCallback? onTap;

  const PropertyCategoryCard({
    Key? key,
    required this.title,
    this.subtitle = '',
    this.iconUrl,
    this.assetIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final path = assetIcon!;
    // ignore: unused_local_variable
    final isSvg = path.toLowerCase().endsWith('.svg'); // Kept variable in case it's needed logic later
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
           color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          
            border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade200
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(path, width: 40.w, height: 40.w, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
