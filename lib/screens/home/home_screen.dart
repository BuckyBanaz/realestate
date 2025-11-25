import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/featured/featured_screen.dart';
import 'package:realestate/screens/search/search_screen.dart';

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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;

            return SingleChildScrollView(
              padding: EdgeInsets.all(pw(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GreetingText(),
                  SizedBox(height: ph(15)),
                  SectionTitle(
                    title: "FEATURED PROPERTIES",
                    actionText: "View all",
                    onActionTap: () {
                      Get.to(const FeaturedScreen());
                    },
                  ),
                  SizedBox(height: ph(15)),
                 _PromotionalBanners(responsiveWidth: screenW),

                  SizedBox(height: ph(15)),
                  SectionTitle(
                    title: "TOP LOCATIONS",
                    actionText: "Explore",
                    onActionTap: () {
                      Get.to(TopLocationsScreen());
                    },
                  ),
                  SizedBox(height: ph(15)),
                  const _TopLocationsSection(),
                  SizedBox(height: ph(8)),
                  const SectionTitle(title: "OUR PROPERTIES"),
                  SizedBox(height: ph(15)),
                  NearbyEstatesSection(),
                ],
              ),
            );
          },
        ),
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
              child: Image.asset("assets/images/logo.png",
                fit: BoxFit.fill,)),
        ),
        SizedBox(height: 30.h,),
        const Spacer(),
        GestureDetector(
          onTap: () => Get.to(SearchScreen()),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
            ),
            child: Icon(
              IconlyLight.search,
              size: 20.w,
              color: secondary,
            ),
          ),
        ),
        SizedBox(width: 6,),
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final banners = [
    {
      "title": "Hisar Sale!",
      "subtitle": "All discounts up to 60%",
      "image":
      "https://images.jdmagicbox.com/comp/bhubaneshwar/dc/0674px674.x674.100320170130.x6x7dc/catalogue/orimark-properties-sahid-nagar-bhubaneshwar-estate-agents-for-residential-rental-3tovu63.jpg",
    },
    {
      "title": "Winter Sale",
      "subtitle": "All discounts up to 40%",
      "image":
      "https://www.jainoncor.com/images/residential-property-banner.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.responsiveWidth * 0.85;
    final double cardHeight = cardWidth * 0.52;

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
                padding: EdgeInsets.only(right: 15.w),
                child: _PromoCard(
                  title: data["title"]!,
                  subtitle: data["subtitle"]!,
                  imageUrl: data["image"]!,
                ),
              );
            },
          ),
        ),

        SizedBox(height: 10),

        // ------- DOT INDICATORS ---------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
                (index) => AnimatedContainer(
              duration: Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? secondary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title, subtitle, imageUrl;
  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(PropertyDetailScreen()),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 100.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Icon(Icons.arrow_forward_outlined, color: Colors.white),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(20.w),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         title,
            //         style: TextStyle(
            //           fontSize: 20.sp,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white,
            //         ),
            //       ),
            //       SizedBox(height: 6.h),
            //       Text(
            //         subtitle,
            //         style: TextStyle(
            //           fontSize: 14.sp,
            //           color: Colors.white,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //       SizedBox(height: 28.h),
            //     ],
            //   ),
            // ),
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
class EstateCard extends StatelessWidget {
  const EstateCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.location,
    required this.price,
    required this.tag,
  }) : super(key: key);

  final String name, rating, location, price, tag;

  @override
  Widget build(BuildContext context) {
    // make card height adapt to parent's height (parent controls height in FEATURED PROPERTIESlist)
    return GestureDetector(
      onTap: () => Get.to(PropertyDetailScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            // left image area proportionally sized
            Flexible(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    "assets/images/1.png",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: secondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.phone_outlined,
                            size: 18.w,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14.w),
                        SizedBox(width: 6.w),
                        Text(
                          rating,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            "($location)",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹$price/month",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                      ),
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
}

// ---------------- TOP LOCATIONS section (unchanged but responsive)
class _TopLocationsSection extends StatelessWidget {
  const _TopLocationsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topLocations.length,
        separatorBuilder: (_, __) => SizedBox(width: 20.w),
        itemBuilder: (context, index) {
          final location = topLocations[index];
          return _LocationCircle(
            imageUrl: location["image"]!,
            title: location["title"]!,
          );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 140.h;

        final double reservedForLabel = (20.h + 8.h); // label height + gap
        final double circleSize = (availableH - reservedForLabel).clamp(
          48.0,
          80.0,
        );

        final double borderWidth = max(2.0, circleSize * 0.06);

        return SizedBox(
          height: availableH,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    LocationDetailScreen(
                      locationName: title,
                      rank: "+4",
                      heroImage: imageUrl,
                      subtitle: "Our recommended real estates in $title",
                    ),
                  );
                },
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: borderWidth),
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final List<Map<String, String>> topLocations = [
  {
    "title": "Sector 15, Hisar",
    "image":
    "https://images.unsplash.com/photo-1600585153490-76fb20a32601?w=600",
  },
  {
    "title": "Hisar \nCantt",
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

// ---------------- Nearby Estates (Grid) - use stable childAspectRatio
class NearbyEstatesSection extends StatelessWidget {
  const NearbyEstatesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: nearbyEstates.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 20.w,
          childAspectRatio: 0.80,
        ),
        itemBuilder: (context, index) {
          final estate = nearbyEstates[index];
          return GestureDetector(
            onTap: () => Get.to(PlotsOnlyScreen()),
            child: NearbyEstateCard(
              imageUrl: estate["image"]!,
              price: estate["price"]!,
              title: estate["title"]!,
              rating: estate["rating"]!,
              location: estate["location"]!,
            ),
          );
        },
      ),
    );
  }
}

class NearbyEstateCard extends StatelessWidget {
  final String imageUrl, price, title, rating, location;

  const NearbyEstateCard({
    required this.imageUrl,
    required this.price,
    required this.title,
    required this.rating,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}


final List<Map<String, String>> nearbyEstates = [
  {
    "title": "TOWNSHIPS",
    "price": "230",
    "rating": "4.8",
    "location": "Sector 15, Hisar",
    "image": "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
  },
  {
    "title": "FARM HOUSES",
    "price": "520",
    "rating": "4.9",
    "location": "Hisar Cantt",
    "image": "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
  },
  {
    "title": "SCOCIETIES",
    "price": "310",
    "rating": "4.7",
    "location": "Rajguru Nagar, Hisar",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
  },
  {
    "title": "PLOTS",
    "price": "275",
    "rating": "4.6",
    "location": "Camp Chowk, Hisar",
    "image": "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
  },{
    "title": "AGRI LAND",
    "price": "310",
    "rating": "4.7",
    "location": "Rajguru Nagar, Hisar",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
  },
  {
    "title": "FLATS / HOUSING",
    "price": "275",
    "rating": "4.6",
    "location": "Camp Chowk, Hisar",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTanvY0hQLQeqkXeywzA5UEDbKcDfx0CpmmUA&s",
  },
];

