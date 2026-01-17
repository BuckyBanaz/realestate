import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';

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
        onTap: () => Get.toNamed(AppRoutes.search),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
           color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade200
          ),
        ),
        child: Row(
          children: [
            Icon(IconlyLight.search, color: Colors.white, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: false,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: "Search House, Apartment, etc.",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
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
              child: Icon(IconlyLight.voice, color: Colors.white, size: 20.w),
            ),
          ],
        ),
      ),
    );
  }
}
