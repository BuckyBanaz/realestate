import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/core/app_theme.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/screens/splash_screen.dart';
import '../screens/onBoard/onboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Recommended (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Real Estate',
          theme: AppTheme.lightTheme,
          home: child,
        );
      },

       child: SplashScreen(),
    );
  }
}
