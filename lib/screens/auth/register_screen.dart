import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/screens/auth/login_screen.dart';

import '../../constant/app_colors.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 40.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Create your ",
                        style: TextStyle(
                          color: secondary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "account",
                        style: TextStyle(
                          color: secondary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // small subtitle
                Text(
                  'quis nostrud exercitation ullamco laboris nisi ut',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 20.h),

                // Name field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'Jhon Doe',
                    suffixIcon: Icon(
                      IconlyLight.profile,
                      color: secondary,
                      size: 20.sp,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 20.h),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '89014141000',
                    suffixIcon: Icon(
                      IconlyLight.call,
                      color: secondary,
                      size: 20.sp,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 20.h),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'jonathan@email.com',
                    suffixIcon: Icon(
                      IconlyLight.message,
                      color: secondary,
                      size: 20.sp,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),

                SizedBox(height: 20.h),

                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 18.h),
                          ),
                          style: TextStyle(letterSpacing: 4.0, fontSize: 14.sp),
                        ),
                      ),
                      Icon(
                        IconlyLight.lock,
                        color: secondary,
                        size: 20.sp,
                      )
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // small row: Terms & show password
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

                SizedBox(height: 30.h),

                // Register button
                Center(
                  child: SizedBox(
                    width: 150.w,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Using email as contact param for OTP screen as earlier
                        Get.to(OTPScreen(contact: _emailController.text.isEmpty ? "chetansharma@gmail.com" : _emailController.text));
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

                SizedBox(height: 18.h),

                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1.h),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1.h),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // Social buttons row (three rounded boxes)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: cardColor,
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
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: Icon(
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
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          child: Icon(
                            FontAwesomeIcons.apple,
                            size: 22.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 22.h),

                // bottom login text
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(const LoginScreen());
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
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
}
