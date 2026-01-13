import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

const baseDur = Duration(milliseconds: 300);
const baseCurve = Curves.easeOutCubic;
Widget stagger(int i, Widget child) => child
    .animate(delay: (150 * i).ms)
    .fadeIn(duration: baseDur, curve: baseCurve)
    .slideY(begin: 0.15, end: 0, duration: baseDur, curve: baseCurve);

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