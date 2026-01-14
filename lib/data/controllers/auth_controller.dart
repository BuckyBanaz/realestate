import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/domain/repo/auth_repository.dart';
import 'package:realestate/screens/home/home_screen.dart'; // Assume Home Screen exists

class AuthController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  var isLoading = false.obs;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter email and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
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
      Fluttertoast.showToast(
        msg: result['message'] ?? "Login Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
          
      // Navigate to Home or Dashboard
       Get.offAllNamed(AppRoutes.home); 
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? "Login Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }

  Future<void> register() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
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
      Fluttertoast.showToast(
        msg: result['message'] ?? "Registration Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
      
      // Navigate to Login Screen
      // We will clear fields optionally
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
      
      Get.offAllNamed(AppRoutes.login);
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? "Registration Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
