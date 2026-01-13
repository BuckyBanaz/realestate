import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/auth/register_screen.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/screens/auth/controller/auth_controller.dart';

import '../../constant/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthController _authController = Get.put(AuthController());
  bool _obscure = true;

  @override
  void dispose() {
    // Controllers are now managed by AuthController, so we don't dispose them here directly 
    // or we leave them to GetX to manage if we used Get.put
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
          color: Theme.of(context).scaffoldBackgroundColor,
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
                  child: const Logoor(),
                ),
            ),
            SizedBox(height: 30.h,),

                // Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stagger(
                      1, RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "",
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 24.sp,
                              ),
                            ),
                            TextSpan(
                              text: "Sign In",
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 23.sp,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 6.h),

                    stagger(
                      2, Text(
                        "Welcome back! Please login to your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 20.h),

                // Email field with outline + inside icon right
                stagger(
                  3,TextFormField(
                    controller: _authController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email / Phone Number',
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
                      fillColor: Theme.of(context).cardColor,
                    ),
                    style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),

                SizedBox(height: 10.h),

                // Password field card (rounded, subtle bg)
                stagger(
                  4, TextFormField(
                    controller: _authController.passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(

                      suffixIcon: GestureDetector(
                        onTap: _togglePassword,
                        child: Icon(
                          _obscure ? IconlyLight.lock:  IconlyLight.unlock,
                          color: secondary,
                          size: 20.sp,
                        ),
                      ),
                      hintText: '••••••••',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    style: TextStyle(letterSpacing: 4.0, fontSize: 14.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),

                SizedBox(height: 10.h),

                // small row: forgot password & show password
                stagger(
                  5, Row(
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
                ),

                SizedBox(height: 20.h),

                // Login button
                stagger(
                  6, Center(
                    child: SizedBox(
                      width: 150.w,
                      height: 50.h,
                      child: Obx(() => ElevatedButton(
                        onPressed: _authController.isLoading.value ? null : () {
                          _authController.login();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          backgroundColor: primary,
                        ),
                        child: _authController.isLoading.value 
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // OR divider
                stagger(
                  7, Row(
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
                ),

                SizedBox(height: 10.h),

                // Social buttons row (three rounded boxes)
                stagger(
                  8, Row(
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
                      SizedBox(width: 10.w,),
                      _circleSocialButton(
                        child: Icon(
                          FontAwesomeIcons.facebookF,
                          size: 22.sp,
                          color: Colors.blueAccent,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w,),
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

                // bottom register text
                stagger(
                  9, GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.signup);
                    },
                    child: Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                          ),
                          Text(
                            'Register',
                            style: TextStyle(
                              color: secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
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
  Widget _circleSocialButton({required Widget child, required VoidCallback onTap}) {
    return Center(
      child: SizedBox(
        height: 50.h,
        width: 50.h, // Circular, so width = height
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).cardColor,
            padding: EdgeInsets.zero,
            side: BorderSide(color: Colors.transparent),
          ),
          child: child,
        ),
      ),
    );
  }

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
            title: Text("Forgot Password", style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    style: TextStyle(fontSize: 15.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
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
              Text("We'll send a password reset link to your email.", style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyLarge?.color)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "you@example.com",
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
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
