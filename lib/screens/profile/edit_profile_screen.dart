import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/controllers/profile_controller.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text("Edit Profile", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      ImageProvider? imageProvider;
                      if (controller.selectedImagePath.isNotEmpty) {
                        imageProvider = FileImage(File(controller.selectedImagePath.value));
                      } else if (controller.currentUser['profile_image'] != null) {
                        imageProvider = NetworkImage(controller.currentUser['profile_image']);
                      }

                      return CircleAvatar(
                        radius: 60.r,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Icon(IconlyBold.profile, size: 40.sp, color: Colors.grey)
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(IconlyBold.camera, size: 20.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Name Field
              _buildTextField(
                context,
                controller: controller.nameController,
                hintText: 'Full Name',
                icon: IconlyLight.profile,
              ),
              const SizedBox(height: 16),

              // Phone Field
              _buildTextField(
                context,
                controller: controller.phoneController,
                hintText: 'Phone Number',
                icon: IconlyLight.call,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                context,
                controller: controller.emailController,
                hintText: 'Email Address',
                icon: IconlyLight.message,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Address Field
              _buildTextField(
                context,
                controller: controller.addressController,
                hintText: 'Address',
                icon: IconlyLight.location,
              ),
              const SizedBox(height: 16),

              // Password Field (Optional as per user request/api)
              _buildTextField(
                context,
                controller: controller.passwordController,
                hintText: 'New Password (Optional)',
                icon: IconlyLight.lock,
                isPassword: true,
              ),

              SizedBox(height: 40.h),

              // Save Button
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () => controller.updateProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Icon(icon, color: secondary),
        hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primary),
        ),
      ),
      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }
}
