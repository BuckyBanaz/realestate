import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/screens/home/home_screen.dart';

import '../../constant/app_colors.dart';
import 'package:realestate/data/controllers/otp_controller.dart';
import '../widgets/helpers.dart';

class OTPScreen extends StatefulWidget {
  final String contact;
  final bool isEmail;

  const OTPScreen({Key? key, required this.contact, this.isEmail = false}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late final TextEditingController _pinController;
  late final OtpController _authC;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _authC = Get.put(OtpController());
    // start timer at 30s
    _authC.startTimer(seconds: 30);
  }

  @override
  void dispose() {
    _pinController.dispose();
    // If you want to remove controller from memory:
    // Get.delete<AuthController>();
    super.dispose();
  }

  void _onOtpCompleted(String pin) {
    _authC.verifyOtp(otp: pin, contact: widget.contact);
  }

  @override
  Widget build(BuildContext context) {
    // Pinput theme (responsive)
    final defaultPinTheme = PinTheme(
      width: 60.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: secondary,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Logo top-left
              stagger(
                0,
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Logoor(),
                ),
              ),
              SizedBox(height: 30.h),

              // Title + subtitle (center)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  stagger(
                    1, Text(
                      "Enter the code",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 23.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                  ),
                  SizedBox(height: 8.h),
                  stagger(
                    2, Text(
                      "Enter the 4 digit code that we just sent to",

                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  stagger(
                    3, Text(
                      widget.contact,
                      style: TextStyle(fontSize: 14.sp, color: secondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Pinput field
              stagger(
                4, Center(
                  child: Pinput(

                    controller: _pinController,
                    length: 4,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: secondary, width: 2),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: const Color(0xFFEFF9EF),
                        border: Border.all(color: primary),
                      ),
                    ),
                    onCompleted: _onOtpCompleted,
                    keyboardType: TextInputType.number,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Timer + resend
              stagger(
                5, Center(
                  child: Obx(() {
                    final seconds = _authC.secondsRemaining.value;
                    final canResend = seconds == 0 && !_authC.isResending.value;
                    return Column(
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     const Icon(Icons.access_time, size: 20, color: Colors.grey),
                        //     SizedBox(width: 8.w),
                        //     Text(
                        //       "00:${seconds.toString().padLeft(2, '0')}",
                        //       style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: canResend
                              ? () => _authC.resendOtp(contact: widget.contact, isEmail: widget.isEmail)
                              : null,
                          child: Text(
                            canResend ? "Resend OTP" : (_authC.isResending.value ? "Resending..." : "Resend in ${seconds}s"),
                            style: TextStyle(
                              color: canResend ? secondary : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        if (_authC.isResending.value) SizedBox(height: 8.h),
                        if (_authC.isResending.value)  CircularProgressIndicator(color:primary,),
                      ],
                    );
                  }),
                ),
              ),

              // const Spacer(),
              //
              // // Optional: manual verify button (if user enters pin and taps)
              // Obx(() {
              //   return Padding(
              //     padding: EdgeInsets.only(bottom: 12.h),
              //     child: SizedBox(
              //       width: double.infinity,
              //       height: 52.h,
              //       child: ElevatedButton(
              //         onPressed: _authC.isVerifying.value
              //             ? null
              //             : () {
              //           final pin = _pinController.text.trim();
              //           if (pin.length != 4) {
              //             Get.snackbar("Invalid", "Enter a 4 digit code", snackPosition: SnackPosition.BOTTOM);
              //             return;
              //           }
              //           _authC.verifyOtp(otp: pin, contact: widget.contact);
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: primary,
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              //         ),
              //         child: _authC.isVerifying.value
              //             ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              //             : Text("Verify & Continue", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700,color: Colors.white)),
              //       ),
              //     ),
              //   );
              // }),
            ],
          ),
        ),
      ),
    );
  }
}