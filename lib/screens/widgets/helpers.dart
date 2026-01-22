import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

const baseDur = Duration(milliseconds: 300);
const baseCurve = Curves.easeOutCubic;
Widget stagger(int i, Widget child) => child
    .animate(delay: (150 * i).ms)
    .fadeIn(duration: baseDur, curve: baseCurve)
    .slideY(begin: 0.15, end: 0, duration: baseDur, curve: baseCurve);
    
String formatPrice(dynamic price) {
  if (price == null) return "0";
  double? priceNum;
  if (price is String) {
    priceNum = double.tryParse(price);
  } else if (price is num) {
    priceNum = price.toDouble();
  }

  if (priceNum == null) return price.toString();

  if (priceNum >= 10000000) {
    return "${(priceNum / 10000000).toStringAsFixed(2)} Cr";
  } else if (priceNum >= 100000) {
    return "${(priceNum / 100000).toStringAsFixed(2)} L";
  } else if (priceNum >= 1000) {
    return "${(priceNum / 1000).toStringAsFixed(2)} K";
  } else {
    return priceNum.toStringAsFixed(0);
  }
}

  Widget circleIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
class Logoor extends StatelessWidget {
  final bool animate;
  const Logoor({super.key, this.animate = false});

  @override
  Widget build(BuildContext context) {
    // Define the parts
    Widget bar = Container(
      width: 4.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );

    Widget textBL = Text(
      "B&L",
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color,
        fontSize: 22.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );

    Widget textsRight = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Real Estate",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        Text(
          "& Constructions",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        Text(
          "PVT. LTD.",
          style: TextStyle(
            color: primary,
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
      ],
    );

    // Apply animations if requested
    if (animate) {
      // 1. Bar appears first
      bar = bar
          .animate()
          .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
          .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);

      // 2. "B&L" appears after slight delay
      textBL = textBL
          .animate(delay: 300.ms)
          .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
          .slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);

      // 3. Right texts appear last
      textsRight = textsRight
          .animate(delay: 700.ms)
          .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
          .slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        bar,
        SizedBox(width: 8.w),
        textBL,
        SizedBox(width: 6.w),
        textsRight,
      ],
    );
  }
}

void showCustomToast(String message, {bool isError = false}) {
  final context = Get.context;
  if (context == null) return;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isError 
                ? Colors.red.withOpacity(0.12) 
                : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: isError 
                  ? Colors.red.withOpacity(0.3) 
                  : primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError ? Colors.redAccent : primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.95) ?? Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: 40.h,
        left: 20.w,
        right: 20.w,
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final String? fallbackAsset;

  const CustomImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fallbackAsset,
  }) : super(key: key);

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/logo.png',
        width: (width != null && width! > 0) ? width! * 0.4 : 40.w,
        height: (height != null && height! > 0) ? height! * 0.4 : 40.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
      return Image.asset(
        fallbackAsset!,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return _buildLogo(context);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();
    if (normalizedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: _buildFallback(context),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        imageUrl: normalizedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder ?? (context, url) => _buildLogo(context),
        errorWidget: errorWidget ?? (context, url, error) => _buildFallback(context),
      ),
    );
  }
}
