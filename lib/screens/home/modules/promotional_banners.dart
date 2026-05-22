import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:get/get.dart';
import 'package:realestate/data/controllers/home_controller.dart';

class PromotionalBanners extends StatefulWidget {
  final double responsiveWidth;
  const PromotionalBanners({Key? key, required this.responsiveWidth})
    : super(key: key);

  @override
  State<PromotionalBanners> createState() => _PromotionalBannersState();
}

class _PromotionalBannersState extends State<PromotionalBanners> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _autoTimer;
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (_pageController.hasClients && controller.newsList.isNotEmpty) {
        final next = (_currentPage + 1) % controller.newsList.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
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

  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').replaceAll('&mdash;', '-').replaceAll('&rdquo;', '"').replaceAll('&ldquo;', '"').trim();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = widget.responsiveWidth * 0.90;
    final double cardHeight = cardWidth * 0.50;

    return Obx(() {
      if (controller.isLoading.value && controller.newsList.isEmpty) {
        return SizedBox(height: cardHeight, child: Center(child: CircularProgressIndicator(color: primary)));
      }
      
      if (controller.newsList.isEmpty) {
        return const SizedBox();
      }

      final items = controller.newsList;

      return Column(
        children: [
          SizedBox(
            height: cardHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (value) {
                setState(() => _currentPage = value);
              },
              itemBuilder: (_, index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: PromoCardWhite(
                    title: item.title,
                    subtitle: _stripHtml(item.description),
                    price: "", // News doesn't have a price
                    badge: item.type.toUpperCase(),
                    imageUrl: item.resourceImage,
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
              items.length,
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
    });
  }
}

class PromoCardWhite extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String badge;
  final String? imageUrl;

  const PromoCardWhite({
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade100
          ),
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
                        // color: const Color(0xFF111827),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (price.isNotEmpty)
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              // color: Colors.black87,
                            ),
                          ),
                        if (price.isNotEmpty)
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
                    ? CustomImage(
                        imageUrl: imageUrl!,
                        width: 140.w,
                        height: double.infinity,
                        borderRadius: 16.r,
                        errorWidget: (_, __, ___) => Center(
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
