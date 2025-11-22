import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/screens/auth/register_screen.dart';

import '../../constant/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _password_controllerDisposeSafety();
    _passwordController.dispose();
    super.dispose();
  }

  // helper in case of accidental refactor mismatch
  void _password_controllerDisposeSafety() {}

  void _togglePassword() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
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
                        text: "Let's ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Sign In",
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

                SizedBox(height: 40.h),

                // Email field with outline + inside icon right
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

                // Password field card (rounded, subtle bg)
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
                            contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                          ),
                          style: TextStyle(letterSpacing: 4.0, fontSize: 14.sp),
                        ),
                      ),
                      GestureDetector(
                        onTap: _togglePassword,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            _obscure ? 'Show' : 'Hide',
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        IconlyLight.lock,
                        color: secondary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // small row: forgot password & show password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                     onTap: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot password?',
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

                // Login button
                Center(
                  child: SizedBox(
                    width: 150.w,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(const RegisterScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: primary,
                      ),
                      child: Text(
                        'Login',
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
                          child: Icon(FontAwesomeIcons.facebook,
                              size: 22.sp, color: Colors.blueAccent),
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
                          child:
                          Icon(FontAwesomeIcons.apple, size: 22.sp, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 22.h),

                // bottom register text
                GestureDetector(
                  onTap: () {
                    Get.to(const RegisterScreen());
                  },
                  child: Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                        ),
                        Text(
                          'Register',
                          style: TextStyle(
                            color: secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
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

  // ... your existing code

  // Yeh function add kar de
  void _showForgotPasswordDialog() {
    if (Platform.isAndroid) {
      // iOS - Cupertino Alert Dialog
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoTheme(
          data: CupertinoThemeData(
            primaryColor: primary, // Button highlight color
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(color: Colors.black), // default text color
            ),
          ),
          child: CupertinoAlertDialog(
            title: Text("Forgot Password", style: TextStyle(fontWeight: FontWeight.w600)),
            content: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text("Enter your email address and we'll send you a link to reset your password."),
                  SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: "you@example.com",
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: Text("Send", style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  // Get.rawSnackbar(
                  //   title: "Success",
                  //   message: "Password reset link sent to your email!",
                  //   backgroundColor: primary,
                  //   borderRadius: 12,
                  //   margin: EdgeInsets.all(16),
                  //   snackPosition: SnackPosition.BOTTOM,
                  //   icon: Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                  //   duration: Duration(seconds: 3),
                  // );
                  },

              ),
            ],
          ),
        ),
      );
    } else {
      // Android - Material Alert Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.bold, color: secondary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("We'll send a password reset link to your email.", style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "you@example.com",
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Get.rawSnackbar(
                //   title: "Success",
                //   message: "Password reset link sent to your email!",
                //   backgroundColor: primary,
                //   borderRadius: 12,
                //   margin: EdgeInsets.all(16),
                //   snackPosition: SnackPosition.BOTTOM,
                //   icon: Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                //   duration: Duration(seconds: 3),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Send"),
            ),
          ],
        ),
      );
    }
  }
}
