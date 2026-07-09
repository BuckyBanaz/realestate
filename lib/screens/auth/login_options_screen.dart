import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/auth/login_screen.dart';
import 'package:realestate/screens/auth/register_screen.dart';

class LoginOptionScreen extends StatelessWidget {
  const LoginOptionScreen({Key? key}) : super(key: key);

  // replace these with your assets or network urls
  final List<String> _images = const [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
  ];

  @override
  Widget build(BuildContext context) {
    // using ScreenUtil so no MediaQuery size direct usage
    final double horizontalPadding = 18.w;
    final double cardRadius = 18.r;
    final double gridGap = 12.w;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // page background like screenshot
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // images grid
                _buildImageGrid(cardRadius, gridGap),

                SizedBox(height: 22.h),

                // heading "Ready to explore?"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ready to ',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: 'explore?',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // green continue button
                Center(
                  child: SizedBox(
                    width: 250.w,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(const LoginScreen());
                      },
                      icon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Continue with Email',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                // divider with OR
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.h,
                        color: Colors.grey[200],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'OR',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.h,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // social buttons row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: Image.asset(
                            "assets/images/google_icon.png",
                            width: 22.w,
                            height: 22.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 70.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.facebook,
                            size: 22.sp,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 70.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.apple,
                            size: 22.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // bottom small text + register
                GestureDetector(
                  onTap: () {
                    Get.to(const RegisterScreen());
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 14.sp,
                              ),
                            ),
                            TextSpan(
                              text: 'Register',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              // could add recognizer for tap
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: builds the 2x2 grid with numbered badges
  Widget _buildImageGrid(double cardRadius, double gap) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _images.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: 1, // square tiles
      ),
      itemBuilder: (context, idx) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // image: replace with Image.asset if local file
              Image.asset(
                _images[idx],
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
