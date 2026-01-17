import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/screens/dashboard/dashboard_screen.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/domain/repo/auth_repository.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class OtpController extends GetxController {
  /// OTP timer (seconds)
  final RxInt secondsRemaining = 30.obs;

  /// Loading states
  final RxBool isResending = false.obs;
  final RxBool isVerifying = false.obs;
  
  final AuthRepository _authRepo = AuthRepository();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
  Future<void> verifyOtp({required String otp, required String contact, bool isForgotPassword = false}) async {
    if (isVerifying.value) return;
    isVerifying.value = true;

    try {
      if (isForgotPassword) {
        // If it's forgot password, we don't verify OTP alone, 
        // usually we show password fields or send them with the reset call.
        // For this flow, we'll keep isVerifying true and wait for password submission.
        isVerifying.value = false; 
        return;
      }

      await Future.delayed(const Duration(seconds: 1)); // simulate network
      Get.offAll(const DashboardScreen());
    } catch (e) {
      showCustomToast("Invalid OTP. Please check the code and try again.", isError: true);
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resetPassword({required String email, required String otp}) async {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      showCustomToast("Please enter and confirm your new password", isError: true);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      showCustomToast("Passwords do not match", isError: true);
      return;
    }

    isVerifying.value = true;
    try {
      final result = await _authRepo.resetPassword(
        email: email,
        otp: otp,
        password: newPasswordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
      );

      if (result['success']) {
        showCustomToast(result['message'] ?? "Password reset successfully");
        Get.offAllNamed(AppRoutes.login);
      } else {
        showCustomToast(result['message'] ?? "Password reset failed", isError: true);
      }
    } catch (e) {
      showCustomToast("An error occurred during password reset", isError: true);
    } finally {
      isVerifying.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    stopTimer();
    super.onClose();
  }
}
