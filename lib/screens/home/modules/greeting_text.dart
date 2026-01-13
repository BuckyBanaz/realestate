import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class GreetingText extends StatelessWidget {
  const GreetingText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final radius = ScreenUtil().scaleWidth > 0 ? 20.r : 20.0;
    return Row(
      children: [
        const Logoor(),
        SizedBox(height: 30.h),
        const Spacer(),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.search),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(shape: BoxShape.circle,  color: Theme.of(context).cardColor,),
            child: Icon(IconlyLight.search, size: 20.w, color: Colors.white),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.notification);
          },
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                ),
                child: Icon(
                  IconlyLight.notification,
                  size: 20.w,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


