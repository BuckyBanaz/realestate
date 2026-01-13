import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/featured/featured_screen.dart';
import 'package:realestate/screens/search/search_screen.dart';
import 'package:realestate/screens/widgets/helpers.dart';

import '../notification/notification_screen.dart';
import '../property/property_deatils_screen.dart';
import '../property/subcategory_screen.dart';
import '../toplocations/locations_details_screen.dart';
import '../toplocations/top_locations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  double _p(BuildContext c, double value) {
    final designWidth = 375.0;
    final w = MediaQuery.of(c).size.width;
    return (value / designWidth) * w;
  }

  @override
  Widget build(BuildContext context) {
    final pw = (double v) => ScreenUtil().scaleWidth > 0 ? v.w : _p(context, v);
    final ph = (double v) => ScreenUtil().scaleHeight > 0
        ? v.h
        : (v / 812.0) * MediaQuery.of(context).size.height;
    final ps = (double v) => ScreenUtil().scaleText > 0
        ? v.sp
        : v * MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stagger(0, _GreetingText()),
                SizedBox(height: ph(15)),
                stagger(
                    1, SearchTextField()),

                SizedBox(height: ph(17)),
                stagger(
                    2, _PromotionalBanners(responsiveWidth: screenW)),
                SizedBox(height: ph(17)),
                stagger(
                    3, const SectionTitle(title: "OUR PROPERTIES")),
                SizedBox(height: ph(8)),
                stagger(
                    4, Categories()),
                SizedBox(height: ph(17)),
                stagger(
                  5, SectionTitle(
                    title: "TOP LOCATIONS",
                    actionText: "Explore",
                    onActionTap: () {
                      Get.to(TopLocationsScreen());
                    },
                  ),
                ),
                SizedBox(height: ph(8)),
                stagger(
                    6, const TopLocationsSection()),
                SizedBox(height: ph(17)),
                stagger(
                  7,SectionTitle(
                    title: "FEATURED PROPERTIES",
                    actionText: "View all",
                    onActionTap: () {
                      Get.to(const FeaturedScreen());
                    },
                  ),
                ),
                SizedBox(height: ph(8)),
                stagger(
                    8, FeaturedPropertiesList()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final radius = ScreenUtil().scaleWidth > 0 ? 20.r : 20.0;
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 70.w,
            height: 50.h,
            child: Image.asset("assets/images/logo.png", fit: BoxFit.fill),
          ),
        ),
        SizedBox(height: 30.h),
        const Spacer(),
        // GestureDetector(
        //   onTap: () => Get.to(SearchScreen()),
        //   child: Container(
        //     padding: EdgeInsets.all(10.w),
        //     decoration: BoxDecoration(shape: BoxShape.circle, color: cardColor),
        //     child: Icon(IconlyLight.search, size: 20.w, color: secondary),
        //   ),
        // ),
        SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Get.to(NotificationScreen());
          },
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                ),
                child: Icon(
                  IconlyLight.notification,
                  size: 20.w,
                  color: secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Search Bar (kept proportional)
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
        onTap: () => Get.to(SearchScreen()),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(IconlyLight.search, color: secondary, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(fontSize: 15.sp, color: secondary),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: "Search House, Apartment, etc.",
                  hintStyle: TextStyle(color: secondary, fontSize: 15.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(width: 1.w, height: 28.h, color: Colors.grey.shade300),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onMicTap,
              child: Icon(IconlyLight.voice, color: secondary, size: 20.w),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Promotional Banners (responsive)
class _PromotionalBanners extends StatefulWidget {
  final double responsiveWidth;
  const _PromotionalBanners({Key? key, required this.responsiveWidth})
    : super(key: key);

  @override
  State<_PromotionalBanners> createState() => _PromotionalBannersState();
}

class _PromotionalBannersState extends State<_PromotionalBanners> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoTimer;

  final List<Map<String, dynamic>> banners = [
    {
      "title": "Hisar — New Flats Available",
      "subtitle": "Modern 2 & 3 BHK apartments • Ready to move",
      "price": "From ₹2.3 Lakh / sq.ft",
      "badge": "Hot",
      "image":
          "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=1200", // optional
    },
    {
      "title": "New Plots Coming Soon",
      "subtitle": "Limited plots in Shree Shyam Kunj — Register interest",
      "price": "Plots from ₹12 Lakh",
      "badge": "Coming Soon",
      "image":
          "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=1200",
    },
    {
      "title": "Family House — Prime Location",
      "subtitle": "3 BHK independent house near Raipur Road",
      "price": "Starting ₹31 Lakh",
      "badge": "Popular",
      "image":
          "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=1200",
    },
  ];

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (_pageController.hasClients && banners.isNotEmpty) {
        final next = (_currentPage + 1) % banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.responsiveWidth * 0.90;
    final double cardHeight = cardWidth * 0.60;

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (value) {
              setState(() => _currentPage = value);
            },
            itemBuilder: (_, index) {
              final data = banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: _PromoCardWhite(
                  title: data["title"] as String,
                  subtitle: data["subtitle"] as String,
                  price: data["price"] as String,
                  badge: data["badge"] as String,
                  imageUrl: data["image"] as String?,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 26.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: _currentPage == index ? primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoCardWhite extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String badge;
  final String? imageUrl;

  const _PromoCardWhite({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.badge,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // card that looks professional and white
    return GestureDetector(
      onTap: () {
        // navigate to detail — replace with your detail screen
        // Get.to(() => PropertyDetailScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Left: text content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top row: badge + spacer
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.local_offer_outlined,
                          size: 18.w,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(child: Container()),
                        // CTA button
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right: optional preview image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              child: Container(
                width: 140.w,
                height: double.infinity,
                color: Colors.grey.shade50,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            IconlyLight.home,
                            size: 36.w,
                            color: Colors.grey[300],
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          IconlyLight.home,
                          size: 36.w,
                          color: Colors.grey[300],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Section Title (unchanged)
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  const SectionTitle({
    required this.title,
    this.actionText,
    this.onActionTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w100,
            color: secondary,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: TextStyle(
                fontSize: 14.sp,
                color: secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
//
// class EstateCard extends StatelessWidget {
//   const EstateCard({
//     Key? key,
//     required this.name,
//     required this.rating,
//     required this.location,
//     required this.price,
//     required this.tag,
//   }) : super(key: key);
//
//   final String name, rating, location, price, tag;
//
//   @override
//   Widget build(BuildContext context) {
//     // make card height adapt to parent's height (parent controls height in FEATURED PROPERTIESlist)
//     return GestureDetector(
//       onTap: () => Get.to(PropertyDetailScreen()),
//       child: Container(
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(24.r),
//         ),
//         child: Row(
//           children: [
//             // left image area proportionally sized
//             Flexible(
//               flex: 4,
//               child: Padding(
//                 padding: EdgeInsets.all(8.w),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20.r),
//                   child: Image.asset(
//                     "assets/images/1.png",
//                     width: double.infinity,
//                     height: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             Flexible(
//               flex: 6,
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.bold,
//                               color: secondary,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.w),
//                           decoration: BoxDecoration(
//                             color: Color(0xFFE8F5E8),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: Icon(
//                             Icons.phone_outlined,
//                             size: 18.w,
//                             color: secondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber, size: 14.w),
//                         SizedBox(width: 6.w),
//                         Text(
//                           rating,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13.sp,
//                           ),
//                         ),
//                         SizedBox(width: 6.w),
//                         Expanded(
//                           child: Text(
//                             "($location)",
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 12.sp,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       "₹$price/month",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                         color: secondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ---------------- Top Locations (as horizontal cards) ----------------
class TopLocationsSection extends StatelessWidget {
  const TopLocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // height tuned for card layout
    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: topLocations.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final location = topLocations[index];
          return _LocationCard(
            imageUrl: location["image"]!,
            title: location["title"]!,
            onTap: () {
              Get.to(
                LocationDetailScreen(
                  locationName: location["title"]!.replaceAll('\n', ' '),
                  rank: "+${index + 1}",
                  heroImage: location["image"]!,
                  subtitle:
                      "Our recommended real estates in ${location["title"]!.split(',').first}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- Single Location Card ----------------
class _LocationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback? onTap;

  const _LocationCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 280.w;
    final double cardHeight = 110.h;
    final double imageWidth = 115.w;
    final double imageHeight = 100.h;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------ IMAGE LEFT ------------
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                imageUrl,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.grey.shade200,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // ----------- CONTENT RIGHT ----------
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F7EE),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "Top location",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Title
                  Text(
                    title.replaceAll('\n', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF083632),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Subtitle
                  Text(
                    "Explore properties, prices and reviews in ${title.split(',').first}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Explore Button + Listings
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Explore",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text("•", style: TextStyle(color: Colors.grey.shade500)),
                      SizedBox(width: 6.w),
                      Text(
                        "${Random().nextInt(20) + 10} listings",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
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
    );
  }
}

// ---------------- sample data ----------------
final List<Map<String, String>> topLocations = [
  {
    "title": "Sector 15, Hisar",
    "image":
        "https://images.unsplash.com/photo-1600585153490-76fb20a32601?w=600",
  },
  {
    "title": "Hisar Cantt",
    "image":
        "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600",
  },
  {
    "title": "Rajguru Nagar, Hisar",
    "image":
        "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600",
  },
  {
    "title": "Model Town, Hisar",
    "image":
        "https://images.unsplash.com/photo-1599423300746-b62533397364?w=600",
  },
];

// ---------------- stub LocationDetailScreen ----------------
// keep your real implementation — this is a quick placeholder so navigation compiles.
// class LocationDetailScreen extends StatelessWidget {
//   final String locationName;
//   final String rank;
//   final String heroImage;
//   final String subtitle;
//
//   const LocationDetailScreen({
//     Key? key,
//     required this.locationName,
//     required this.rank,
//     required this.heroImage,
//     required this.subtitle,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(locationName)),
//       body: Center(child: Text(subtitle)),
//     );
//   }
// }

// ---------------- Example horizontal list (use on home screen) ----------------
class FeaturedPropertiesList extends StatelessWidget {
  const FeaturedPropertiesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // compact horizontal cards
    final double listHeight = 150.h;
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: nearbyEstates.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (ctx, i) {
          final e = nearbyEstates[i];
          return GestureDetector(
            onTap: () => Get.to(PropertyDetailScreen()),
            // onTap: () =>
            //     Get.to(() => PlotsOnlyScreen()), // replace with detail screen
            child: FeatureCard(
              imageUrl: e['image']!,
              title: e['title']!,
              location: e['location']!,
              price: e['price']!,
              beds: e['beds']!,
              area: e['area']!,
              tag: e['tag']!,
              rating: e['rating']!,
            ),
          );
        },
      ),
    );
  }
}

// ---------------- The LocationCard (featured-style compact) ----------------
class FeatureCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;
  final String beds;
  final String area;
  final String tag;
  final String rating;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 320.w;
    final double cardHeight = 140.h;
    final double imageW = 120.w;
    final double imageH = 110.h;
    final borderRadius = 12.r;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // image left (larger, fills area)
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              imageUrl,
              width: imageW,
              height: imageH,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: imageW,
                height: imageH,
                color: Colors.grey.shade200,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // right content (compact column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // small tag row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F7EE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Spacer(),
                    // rating small pill
                    Row(
                      children: [
                        Icon(Icons.star, size: 12.w, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF083632),
                  ),
                ),

                SizedBox(height: 4.h),

                // location
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: 4.h),

                // attributes row + price + view
                Row(
                  children: [
                    // attributes (beds, area)
                    Text(
                      "$beds • $area",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // price
                    Text(
                      "₹$price",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // view button
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "View",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

// Placeholder detail screen — replace with your real page
// class PlotsOnlyScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text("Property")),
//     body: Center(child: Text("Property detail here")),
//   );
// }

const Color _kPrimary = Color(0xFF0B6EFD);
const Color _kAccent = Color(0xFF0DB6A6);
const Color kCardBorder = Color(0xFFEFEFF1);
const Color _kTitle = Color(0xFF004C45);

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
      height: 88.h,
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
              onTap: () => Get.to(PlotsOnlyScreen()),
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
    final isSvg = path.toLowerCase().endsWith('.svg');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: kCardBorder),
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
            SvgPicture.asset(path, width: 50, height: 50, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _kTitle,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
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
