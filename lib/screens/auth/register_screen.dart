import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/screens/auth/login_screen.dart';

import '../../Routes/appRoutes.dart';
import '../../constant/app_colors.dart';
import '../widgets/helpers.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    // Using ScreenUtil for responsive sizes
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                stagger(
                  0,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary,  // ✔ allowed inside decoration
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 40.w,
                          height:30.h,
                          child: Image.asset(
                            "assets/images/logo.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stagger(
                      1,
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 23.sp,
                                  ),
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 23.sp,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    stagger(
                      2,
                      Text(
                        "Join us and get started in a few easy steps.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Name field
                stagger(
                  3,
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Chetan',
                      suffixIcon: Icon(
                        IconlyLight.profile,
                        color: secondary,
                        size: 20.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                SizedBox(height: 10.h),

                // Phone field
                stagger(
                  4,
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '0000000000',
                      suffixIcon: Icon(
                        IconlyLight.call,
                        color: secondary,
                        size: 20.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                SizedBox(height: 10.h),

                // Email field
                stagger(
                  5,
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'chetan@email.com',
                      suffixIcon: Icon(
                        IconlyLight.message,
                        color: secondary,
                        size: 20.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),

                SizedBox(height: 10.h),

                // Password field
                stagger(
                  6,
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        _obscure ? IconlyLight.lock : IconlyLight.unlock,
                        color: secondary,
                        size: 20.sp,
                      ),
                      hintText: '••••••••',
                      filled: true,
                      fillColor: cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    style: TextStyle(letterSpacing: 4.0, fontSize: 14.sp),
                  ),
                ),

                SizedBox(height: 10.h),

                // small row: Terms & show password
                stagger(
                  7,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Text(
                          'Terms of service',
                          style: TextStyle(
                            color: secondary,
                            fontWeight: FontWeight.w200,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _togglePassword,
                        child: Text(
                          _obscure ? 'Show password' : 'Hide password',
                          style: TextStyle(
                            color: secondary,
                            fontWeight: FontWeight.w200,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Register button
                stagger(
                  8,
                  Center(
                    child: SizedBox(
                      width: 150.w,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(
                            OTPScreen(
                              contact: _emailController.text.isEmpty
                                  ? "chetansharma@gmail.com"
                                  : _emailController.text,
                            ),
                          );

                          // Using email as contact param for OTP screen as earlier
                          // Get.to(OTPScreen(contact: _emailController.text.isEmpty ? "chetansharma@gmail.com" : _emailController.text));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // OR divider
                stagger(
                  9,
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1.h),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Divider(color: Colors.grey[300], thickness: 1.h),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Social buttons row (three rounded boxes)
                stagger(
                  10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleSocialButton(
                        child: Image.asset(
                          "assets/images/google_icon.png",
                          width: 22.w,
                          height: 22.h,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      _circleSocialButton(
                        child: Icon(
                          FontAwesomeIcons.facebookF,
                          size: 22.sp,
                          color: Colors.blueAccent,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      _circleSocialButton(
                        child: Icon(
                          FontAwesomeIcons.apple,
                          size: 22.sp,
                          color: Colors.black,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // bottom login text
                stagger(
                  11, Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.signup);
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleSocialButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Center(
      child: SizedBox(
        height: 50.h,
        width: 50.h, // Circular, so width = height
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: cardColor,
            padding: EdgeInsets.zero,
            side: BorderSide(color: Colors.transparent),
          ),
          child: child,
        ),
      ),
    );
  }
}
