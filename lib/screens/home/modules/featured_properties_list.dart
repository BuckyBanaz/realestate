import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class FeaturedPropertiesList extends StatelessWidget {
  const FeaturedPropertiesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adjusted height for a more compact list
    final double listHeight = 155.h;
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w), // Match home padding
        scrollDirection: Axis.horizontal,
        itemCount: nearbyEstates.length,
        clipBehavior: Clip.none,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (ctx, i) {
          final e = nearbyEstates[i];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.propertyDetail),
            child: SizedBox(
              width: 280.w, // Restore fixed width here for horizontal list
              child: FeatureCard(
                imageUrl: e['image']!,
                title: e['title']!,
                location: e['location']!,
                price: e['price']!,
                beds: e['beds']!,
                area: e['area']!,
                tag: e['tag']!,
                rating: e['rating']!,
                onFavoritePressed: () {
                  // Handle favorite toggle
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String beds;
  final String area;
  final String tag;
  final String rating;
  final double? width;
  final VoidCallback? onFavoritePressed;

  const FeatureCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.beds,
    required this.area,
    required this.tag,
    required this.rating,
    this.width,
    this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dimens adjusted for flexibility
    final double cardHeight = 145.h;
    final double imageW = 115.w;
    final double imageH = double.infinity;
    final borderRadius = 18.r;

    return Container(
      width: width ?? double.infinity,
      height: cardHeight,
      constraints: width == null ? null : BoxConstraints(maxWidth: 300), 
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Row(
          children: [
            // Left: Image with Overlay Elements
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: imageW,
                  height: imageH,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: imageW,
                    height: imageH,
                    color: Colors.grey.shade900,
                    child: Icon(IconlyLight.image, color: Colors.grey.shade700, size: 20.sp),
                  ),
                ),
                Container(
                  width: imageW,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: secondary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Right: Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                            SizedBox(width: 3.w),
                            Text(
                              rating,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onFavoritePressed,
                          child: Icon(
                            IconlyLight.heart,
                            size: 16.sp,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Row(
                      children: [
                        Icon(IconlyLight.location, size: 10.sp, color: secondary),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMiniDetail(IconlyLight.info_square, beds),
                            SizedBox(height: 2.h),
                            _buildMiniDetail(IconlyLight.discovery, area),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹$price",
                              style: TextStyle(
                                color: primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDetail(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 10.sp, color: Colors.white.withOpacity(0.5)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}


// ---------------- Dummy richer data for nearbyEstates ----------------
final List<Map<String, String>> nearbyEstates = [
  {
    "title": "Shree Shyam Kunj — Plot No. 5",
    "price": "12,00,000",
    "rating": "4.8",
    "location": "Sector 15, Hisar",
    "image":
        "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    "beds": "—", // plots don't have beds; keep placeholder
    "area": "200 sq.m",
    "tag": "Top",
  },
  {
    "title": "Fairview Apartment — 2 BHK",
    "price": "23,00,000",
    "rating": "4.9",
    "location": "Hisar Cantt",
    "image":
        "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
    "beds": "2 BHK",
    "area": "95 sq.m",
    "tag": "Hot",
  },
  {
    "title": "Rajguru Farmhouse",
    "price": "31,00,000",
    "rating": "4.7",
    "location": "Rajguru Nagar, Hisar",
    "image":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
    "beds": "3 BHK",
    "area": "250 sq.m",
    "tag": "Popular",
  },
  {
    "title": "Plot — Camp Chowk (East)",
    "price": "9,50,000",
    "rating": "4.6",
    "location": "Camp Chowk, Hisar",
    "image":
        "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
    "beds": "—",
    "area": "150 sq.m",
    "tag": "New",
  },
  {
    "title": "Green Acres — Agricultural Land",
    "price": "18,00,000",
    "rating": "4.7",
    "location": "Rajguru Nagar, Hisar",
    "image":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
    "beds": "—",
    "area": "500 sq.m",
    "tag": "Agri",
  },
];
