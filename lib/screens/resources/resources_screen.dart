import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/resources/area_converter_screen.dart';
import 'package:realestate/screens/resources/emi_calculator_screen.dart';
import 'package:realestate/screens/resources/resource_map_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldColor,
        title: Text(
          'Resources',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(
              'Quick Tools',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Utilities to help with property decisions and planning.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
            SizedBox(height: 18.h),
            _resourceTile(
              context,
              title: 'Map',
              subtitle: 'Sites Map Plans',
              icon: Icons.map_outlined,
              onTap: () => Get.to(() => const ResourceMapScreen()),
            ),
            SizedBox(height: 12.h),
            _resourceTile(
              context,
              title: 'EMI Calculator',
              subtitle: 'Calculate monthly payments',
              icon: Icons.calculate_outlined,
              onTap: () => Get.to(() => const EmiCalculatorScreen()),
            ),
            SizedBox(height: 12.h),
            _resourceTile(
              context,
              title: 'Area Converter',
              subtitle: 'Convert plot area units',
              icon: Icons.swap_horiz_rounded,
              onTap: () => Get.to(() => const AreaConverterScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resourceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
