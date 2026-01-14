import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/constant/app_colors.dart';

class OtpController extends GetxController {
  /// OTP timer (seconds)
  final RxInt secondsRemaining = 30.obs;

  /// Loading states
  final RxBool isResending = false.obs;
  final RxBool isVerifying = false.obs;

  Timer? _timer;

  /// Start or restart the timer with given seconds (default 30)
  void startTimer({int seconds = 30}) {
    stopTimer();
    secondsRemaining.value = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resend OTP placeholder
  Future<void> resendOtp({required String contact, bool isEmail = false}) async {
    if (isResending.value) return;
    isResending.value = true;

    try {
      // TODO: call your resend API here
      await Future.delayed(const Duration(seconds: 1)); // simulate network

      // restart timer after resend
      startTimer(seconds: 30);

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("A new OTP has been sent to $contact"),
          backgroundColor: secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Failed to resend OTP. Try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      isResending.value = false;
    }
  }

  /// Verify OTP placeholder
  Future<void> verifyOtp({required String otp, required String contact}) async {
    if (isVerifying.value) return;
    isVerifying.value = true;

    try {
      // TODO: call your verify API here
      await Future.delayed(const Duration(seconds: 1)); // simulate network

      // On success navigate to dashboard (replace with your logic)
      Get.offAll(const DashboardScreen());
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP. Please check the code and try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      isVerifying.value = false;
    }
  }

  @override
  void onClose() {
    stopTimer();
    super.onClose();
  }
}
