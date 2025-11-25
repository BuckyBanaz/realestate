import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/screens/auth/login_options_screen.dart';

import '../../constant/app_colors.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.r),
          child: Stack(
            children: [
              // Background image (opening.png)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/onboard_3.png',
                  fit: BoxFit.cover,
                ),
              ),

              // semi transparent color overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.2),
                  ),
                ),
              ),

              // gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        primary,
                      ],
                    ),
                  ),
                ),
              ),

              // Center logo/text
              Positioned.fill(
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                  ),
                ),
              ),

              // Bottom buttons area
              Positioned(
                bottom: 60.h,
                left: 40.w,
                right: 40.w,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 220.w,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(const LoginOptionScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary, // green
                            foregroundColor: Colors.white, // text color
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            "let’s start",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "v1.0.0",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({Key? key}) : super(key: key);

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _page = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      titleParts: [
        'Find best place\nto stay in ',
        'good price',
      ],
      subtitle: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.',
      imageAsset: 'assets/images/onboard_1.png',
    ),
    _OnboardData(
      titleParts: [
        'Fast sell your property\nin just ',
        'one click',
      ],
      subtitle: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.',
      imageAsset: 'assets/images/onboard_2.png',
    ),
    _OnboardData(
      titleParts: [
        'Find ',
        'perfect choice',
        ' for\nyour future house',
      ],
      subtitle: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed.',
      imageAsset: 'assets/images/onboard_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      _pageController.animateToPage(_page + 1,
          duration: const Duration(milliseconds: 350), curve: Curves.ease);
    } else {
      Get.to(const LoginOptionScreen());
      // last page -> navigate to login options
    }
  }

  void _previousPage() {
    if (_page > 0) {
      _pageController.animateToPage(_page - 1,
          duration: const Duration(milliseconds: 350), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Size s = MediaQuery.of(context).size; // not needed now since using ScreenUtil
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // top row: skip button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.to(const LoginOptionScreen());
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Text(
                                'skip',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        // Title (with highlighted parts)
                        _buildTitle(data),

                        SizedBox(height: 10.h),

                        // subtitle
                        Text(
                          data.subtitle,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14.sp),
                        ),
                        SizedBox(height: 10.h),

                        // big image card
                        Center(
                          child: SizedBox(
                            height: 500.h,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40.r),
                              child: Stack(
                                children: [
                                  // Image fill
                                  Positioned.fill(
                                    child: Image.asset(
                                      data.imageAsset,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // bottom overlay area for buttons
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 18.h,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 22.w),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: _OnboardProgressPill(
                                              pageIndex: _page,
                                              pageCount: _pages.length,
                                              width: 120.w, // total pill width
                                              height: 8.h, // pill height
                                              backgroundColor:
                                              Colors.grey.withOpacity(0.4),
                                              fillColor: Colors.white,
                                              duration:
                                              const Duration(milliseconds: 300),
                                            ),
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              // back circular button (only if not first)
                                              if (index != 0)
                                                GestureDetector(
                                                  onTap: _previousPage,
                                                  child: Container(
                                                    width: 44.w,
                                                    height: 44.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.08),
                                                          blurRadius: 6.r,
                                                          offset: Offset(0, 3.h),
                                                        )
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      Icons.arrow_back,
                                                      size: 20.sp,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(width: 10.w),
                                              SizedBox(
                                                height: 50.h,
                                                width: 180.w,
                                                child: ElevatedButton(
                                                  onPressed: _nextPage,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: primary,
                                                    elevation: 0,
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    index == _pages.length - 1
                                                        ? 'Get Started'
                                                        : 'Next',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                        FontWeight.w600),
                                                  ),
                                                ),
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
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(_OnboardData data) {
    // build RichText where highlighted parts are green/blue
    List<TextSpan> spans = [];

    if (data.titleParts.length == 2) {
      spans.add(TextSpan(
        text: data.titleParts[0],
        style: TextStyle(
            color: Colors.black87, fontSize: 28.sp, height: 1.2.h),
      ));
      spans.add(TextSpan(
        text: data.titleParts[1],
        style: TextStyle(
            color: const Color(0xFF14335D),
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.2.h),
      ));
    } else if (data.titleParts.length == 3) {
      spans.add(TextSpan(
        text: data.titleParts[0],
        style: TextStyle(
            color: Colors.black87, fontSize: 28.sp, height: 1.2.h),
      ));
      spans.add(TextSpan(
        text: data.titleParts[1],
        style: TextStyle(
            color: const Color(0xFF14335D),
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.2.h),
      ));
      spans.add(TextSpan(
        text: data.titleParts[2],
        style: TextStyle(
            color: Colors.black87, fontSize: 28.sp, height: 1.2.h),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class _OnboardData {
  final List<String> titleParts;
  final String subtitle;
  final String imageAsset;

  _OnboardData({
    required this.titleParts,
    required this.subtitle,
    required this.imageAsset,
  });
}

class _OnboardProgressPill extends StatelessWidget {
  final int pageIndex;
  final int pageCount;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color fillColor;
  final Duration duration;

  const _OnboardProgressPill({
    Key? key,
    required this.pageIndex,
    required this.pageCount,
    this.width = 120,
    this.height = 8,
    this.backgroundColor = const Color(0xFFBDBDBD),
    this.fillColor = Colors.white,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // fraction of fill: e.g. for 3 pages -> pageIndex 0 => 0.33, 1 => 0.66, 2 => 1.0
    final double fraction = (pageIndex + 1) / pageCount;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height * 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height * 2),
        child: Stack(
          children: [
            // animated filled part
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              width: width * fraction,
              height: height,
              // Use Align to ensure left alignment
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: width * fraction,
                  height: height,
                  color: fillColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _NearbyFacility extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _NearbyFacility({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
