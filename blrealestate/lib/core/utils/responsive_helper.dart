import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 360 &&
      MediaQuery.of(context).size.width < 600;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static double getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.85;
    if (width > 600) return baseSize * 1.15;
    return baseSize;
  }

  /// Horizontal padding that scales with screen width
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 16.0;
    if (width >= 600) return 32.0;
    return 20.0;
  }

  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 800) return 2;
    return 4;
  }

  static double getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.4;
    return 1.6;
  }

  /// Safe bottom padding (home indicator on iPhone, nav bar on Android)
  static double safeBottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;
}
