import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/domain/repo/auth_repository.dart';
import 'package:realestate/screens/home/home_screen.dart'; // Assume Home Screen exists
import 'package:realestate/screens/widgets/helpers.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();

  var isLoading = false.obs;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showCustomToast("Please enter email and password", isError: true);
      return;
    }

    isLoading.value = true;
    
    // Call Repo
    final result = await _authRepo.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    isLoading.value = false;

    if (result['success']) {
      showCustomToast(result['message'] ?? "Login Successful");
          
      // Navigate to Home or Dashboard
       Get.offAllNamed(AppRoutes.home); 
    } else {
      showCustomToast(result['message'] ?? "Login Failed", isError: true);
    }
  }

  Future<void> register() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      showCustomToast("Please fill all fields", isError: true);
      return;
    }

    isLoading.value = true;

    final result = await _authRepo.register(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    isLoading.value = false;

    if (result['success']) {
      showCustomToast("Registration Successful. Now enter email and password to login");
      
      // Navigate to Login Screen
      // We will clear fields optionally
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
      
      Get.offAllNamed(AppRoutes.login);
    } else {
      showCustomToast(result['message'] ?? "Registration Failed", isError: true);
    }
  }
  
  Future<void> forgotPassword() async {
    final email = forgotPasswordEmailController.text.trim();
    if (email.isEmpty) {
      showCustomToast("Please enter your email", isError: true);
      return;
    }

    isLoading.value = true;
    final result = await _authRepo.forgotPassword(email);
    isLoading.value = false;

    if (result['success']) {
      showCustomToast(result['message'] ?? "OTP sent to your email");
      Get.toNamed(AppRoutes.otp, arguments: {
        'contact': email,
        'isEmail': true,
        'isForgotPassword': true,
      });
    } else {
      showCustomToast(result['message'] ?? "Failed to send OTP", isError: true);
    }
  }

  @override
  void onClose() {
    forgotPasswordEmailController.dispose();
    super.onClose();
  }
}
