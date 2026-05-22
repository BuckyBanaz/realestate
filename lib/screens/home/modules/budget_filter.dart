import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/home_controller.dart';

class BudgetFilterWidget extends StatelessWidget {
  const BudgetFilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Premium dark card matching theme
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price Range",
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Set your budget to filter properties",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              // Clear Budget button
              Obx(() {
                final hasBudget = controller.minPrice.value.isNotEmpty || controller.maxPrice.value.isNotEmpty;
                if (!hasBudget) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.minPriceController.clear();
                    controller.maxPriceController.clear();
                    controller.minPrice.value = "";
                    controller.maxPrice.value = "";
                    controller.fetchFilteredProperties(forceRefreshNetwork: false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "Reset",
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildPriceField("Min Price", controller.minPriceController),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPriceField("Max Price", controller.maxPriceController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String hint, TextEditingController textController) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.currency_rupee, color: primary, size: 14.sp),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 13.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}
