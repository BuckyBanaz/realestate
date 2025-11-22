import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/featured/featured_screen.dart';

import '../notification/notification_screen.dart';
import '../property/property_deatils_screen.dart';
import '../toplocations/locations_details_screen.dart';
import '../toplocations/top_locations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Helper to get proportional size using MediaQuery (fallback if ScreenUtil not initialized)
  double _p(BuildContext c, double value) {
    // Treat value as design px for width (375 designWidth)
    final designWidth = 375.0;
    final w = MediaQuery.of(c).size.width;
    return (value / designWidth) * w;
  }

  @override
  Widget build(BuildContext context) {
    // Use ScreenUtil values if available, otherwise use proportional helper
    final pw = (double v) => ScreenUtil().scaleWidth > 0 ? v.w : _p(context, v);
    final ph = (double v) => ScreenUtil().scaleHeight > 0 ? v.h : (v / 812.0) * MediaQuery.of(context).size.height;
    final ps = (double v) => ScreenUtil().scaleText > 0 ? v.sp : v * MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight;

          return SingleChildScrollView(
            padding: EdgeInsets.all(pw(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GreetingText(),
                SizedBox(height: ph(8)),
                SearchTextField(
                  controller: TextEditingController(),
                  onChanged: (value) {
                    debugPrint("Searching: $value");
                  },
                  onMicTap: () {
                    debugPrint("Voice search tapped!");
                  },
                  // pass helpers to keep internal sizes consistent
                ),
                SizedBox(height: ph(20)),
                const _CategoryChips(),
                SizedBox(height: ph(30)),

                // Promotional banners - width-based aspect ratio so it behaves same on all screens
                _PromotionalBanners(responsiveWidth: screenW),

                SizedBox(height: ph(30)),
                SectionTitle(
                  title: "Featured Estates",
                  actionText: "view all",
                  onActionTap: () {
                    Get.to(const FeaturedScreen());
                  },
                ),
                SizedBox(height: ph(16)),

                // Featured list with width-based card sizes
                _FeaturedEstatesList(responsiveWidth: screenW),

                SizedBox(height: ph(30)),
                SectionTitle(
                  title: "Top Locations",
                  actionText: "explore",
                  onActionTap: () {
                    Get.to(TopLocationsScreen());
                  },
                ),
                SizedBox(height: ph(16)),
                const _TopLocationsSection(),
                SizedBox(height: ph(16)),
                const SectionTitle(title: "Explore Nearby Estates"),
                SizedBox(height: ph(16)),
                NearbyEstatesSection(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------- Greeting Text (unchanged)
class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final radius = ScreenUtil().scaleWidth > 0 ? 20.r : 20.0;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey, Jonathan!",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
            ),
            Text(
              "Let's start exploring",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
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
                  border: Border.all(color: primary, width: 2.w),
                ),
                child: Icon(
                  IconlyLight.notification,
                  size: 20.w,
                  color: secondary,
                ),
              ),
              Positioned(
                right: 12.w,
                top: 12.h,
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        CircleAvatar(
          radius: 20.r,
          backgroundImage: const NetworkImage("https://i.pravatar.cc/300?u=jonathan"),
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
    return Container(
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
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
              decoration: InputDecoration(
                hintText: "Search House, Apartment, etc.",
                hintStyle: TextStyle(color: secondary, fontSize: 15.sp),
                border: OutlineInputBorder(
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
    );
  }
}

// ---------------- Category Chips (unchanged)
class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "House", "Apartment", "Villa"];
    return SizedBox(
      height: 35.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: isSelected ? secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              categories[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Promotional Banners (responsive)
class _PromotionalBanners extends StatelessWidget {
  final double responsiveWidth;
  const _PromotionalBanners({Key? key, required this.responsiveWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use width to derive height so cards scale same across devices
    final cardWidth = responsiveWidth * 0.8; // each card width
    final cardHeight = cardWidth * 0.52; // aspect ratio ~ 1.92

    final banners = [
      {
        "title": "Halloween Sale!",
        "subtitle": "All discounts up to 60%",
        "image": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
      },
      {
        "title": "Summer Vacation",
        "subtitle": "All discounts up to 40%",
        "image": "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800",
      },
    ];

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (_, index) {
          final data = banners[index];
          return SizedBox(
            width: cardWidth,
            child: _PromoCard(
              title: data["title"]!,
              subtitle: data["subtitle"]!,
              imageUrl: data["image"]!,
            ),
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title, subtitle, imageUrl;
  const _PromoCard({required this.title, required this.subtitle, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.85)],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 100.w,
              height: 40.h,
              decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.only(topRight: Radius.circular(20.r))),
              child: Icon(Icons.arrow_forward_outlined, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 6.h),
                Text(subtitle, style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                SizedBox(height: 28.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Section Title (unchanged)
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  const SectionTitle({required this.title, this.actionText, this.onActionTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: secondary)),
      if (actionText != null)
        GestureDetector(onTap: onActionTap, child: Text(actionText!, style: TextStyle(fontSize: 14.sp, color: secondary, fontWeight: FontWeight.w600))),
    ]);
  }
}

// ---------------- Featured Estates list (responsive card widths)
class _FeaturedEstatesList extends StatelessWidget {
  final double responsiveWidth;
  const _FeaturedEstatesList({Key? key, required this.responsiveWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // cardWidth relative to screen width
    final cardWidth = responsiveWidth * 0.78;
    final cardHeight = cardWidth * 0.36;

    final items = [
      {"name": "Sky Dandelions Apartment", "rating": "4.9", "loc": "Jakarta, Indonesia", "price": "290", "tag": "Apartment"},
      {"name": "Villa with Amazing Pool", "rating": "4.8", "loc": "Bali", "price": "450", "tag": "Villa"},
      {"name": "Modern Minimal House", "rating": "4.7", "loc": "Bandung", "price": "320", "tag": "House"},
    ];

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (_, index) {
          final data = items[index];
          return SizedBox(
            width: cardWidth,
            child: EstateCard(
              name: data["name"]!,
              rating: data["rating"]!,
              location: data["loc"]!,
              price: data["price"]!,
              tag: data["tag"]!,
            ),
          );
        },
      ),
    );
  }
}

class EstateCard extends StatelessWidget {
  const EstateCard({Key? key, required this.name, required this.rating, required this.location, required this.price, required this.tag})
      : super(key: key);

  final String name, rating, location, price, tag;

  @override
  Widget build(BuildContext context) {
    // make card height adapt to parent's height (parent controls height in featured list)
    return GestureDetector(
      onTap: () => Get.to(PropertyDetailScreen()),
      child: Container(
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12.r, offset: Offset(0, 6.h))]),
        child: Row(
          children: [
            // left image area proportionally sized
            Flexible(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset("assets/images/1.png", width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: secondary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Color(0xFFE8F5E8), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.phone_outlined, size: 18.w, color: secondary))
                  ]),
                  Row(children: [Icon(Icons.star, color: Colors.amber, size: 14.w), SizedBox(width: 6.w), Text(rating, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)), SizedBox(width: 6.w), Expanded(child: Text("($location)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp), overflow: TextOverflow.ellipsis))]),
                  Text("\$$price/month", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: secondary))
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- Top Locations section (unchanged but responsive)
class _TopLocationsSection extends StatelessWidget {
  const _TopLocationsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topLocations.length,
        separatorBuilder: (_, __) => SizedBox(width: 20.w),
        itemBuilder: (context, index) {
          final location = topLocations[index];
          return _LocationCircle(imageUrl: location["image"]!, title: location["title"]!);
        },
      ),
    );
  }
}

class _LocationCircle extends StatelessWidget {
  final String imageUrl;
  final String title;
  const _LocationCircle({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // available height coming from parent (may be finite like 117.2)
      final double availableH = constraints.maxHeight.isFinite ? constraints.maxHeight : 140.h;

      // reserve approximate space for label + spacing
      final double reservedForLabel = (20.h + 8.h); // label height + gap
      // compute circle size from remaining space, clamp to reasonable range
      final double circleSize = (availableH - reservedForLabel).clamp(48.0, 80.0);

      // border width proportional but not too large
      final double borderWidth = max(2.0, circleSize * 0.06);

      return SizedBox(
        // ensure the widget itself doesn't exceed the available height
        height: availableH,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(LocationDetailScreen(
                  locationName: title,
                  rank: "+4",
                  heroImage: imageUrl,
                  subtitle: "Our recommended real estates in $title",
                ));
              },
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  border: Border.all(color: Colors.white, width: borderWidth),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6.0, offset: Offset(0, 4))],
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Let the text take remaining space if needed without overflowing
            Flexible(
              child: SizedBox(
                width: circleSize,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: secondary),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}


final List<Map<String, String>> topLocations = [
  {"title": "Bali", "image": "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=500"},
  {"title": "Jakarta", "image": "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=500"},
  {"title": "Yogyakarta", "image": "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800"},
  {"title": "Bandung", "image": "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=500"},
];

// ---------------- Nearby Estates (Grid) - use stable childAspectRatio
class NearbyEstatesSection extends StatelessWidget {
  const NearbyEstatesSection();

  @override
  Widget build(BuildContext context) {
    // choose a childAspectRatio that looks good on many screens
    final childAspect = 0.70;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nearbyEstates.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: childAspect,
      ),
      itemBuilder: (context, index) {
        final estate = nearbyEstates[index];
        return _NearbyEstateCard(
          imageUrl: estate["image"]!,
          price: estate["price"]!,
          title: estate["title"]!,
          rating: estate["rating"]!,
          location: estate["location"]!,
        );
      },
    );
  }
}

class _NearbyEstateCard extends StatelessWidget {
  final String imageUrl, price, title, rating, location;
  const _NearbyEstateCard({required this.imageUrl, required this.price, required this.title, required this.rating, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r), color: cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12.r, offset: Offset(0, 6.h))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 6,
          child: Stack(children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(borderRadius: BorderRadius.circular(20.r), child: Image.asset(imageUrl, fit: BoxFit.cover)),
              ),
            ),
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.r)]), child: Icon(IconlyLight.heart, size: 20.w, color: Colors.red.shade400)),
            ),
            Positioned(
              bottom: 14.h,
              right: 12.w,
              child: Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(30.r)), child: Text("\$$price/month", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp))),
            ),
          ]),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              Row(children: [Icon(Icons.star, color: Colors.amber, size: 14.w), SizedBox(width: 4.w), Text(rating, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)), SizedBox(width: 6.w), Expanded(child: Text(location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp), overflow: TextOverflow.ellipsis))])
            ]),
          ),
        )
      ]),
    );
  }
}

final List<Map<String, String>> nearbyEstates = [
  {"title": "Wings Tower", "price": "220", "rating": "4.9", "location": "Jakarta, Indonesia", "image": "assets/images/onboard_1.png"},
  {"title": "Mill Sper House", "price": "271", "rating": "4.8", "location": "Jakarta, Indonesia", "image": "assets/images/onboard_2.png"},
  {"title": "Bungalow House", "price": "235", "rating": "4.7", "location": "Bandung", "image": "assets/images/onboard_3.png"},
  {"title": "Sky Dandelions", "price": "290", "rating": "4.9", "location": "Jakarta, Indonesia", "image": "assets/images/onboard_3.png"},
];
