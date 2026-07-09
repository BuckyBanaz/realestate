import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "Last Updated: July 2026",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 20.h),
              _buildSectionCard(
                context: context,
                title: "1. Introduction",
                content: "Welcome to B&L app. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.",
              ),
              _buildSectionCard(
                context: context,
                title: "2. Information We Collect",
                content: "We collect personal information that you voluntarily provide to us when registering or expressing interest in properties, such as name, email address, contact information, and preferences. We also collect usage and device information to optimize search results.",
              ),
              _buildSectionCard(
                context: context,
                title: "3. How We Use Your Information",
                content: "We use the information we collect to operate and maintain the application, show personalized real estate suggestions, enable property inquiries, verify transaction records, send notifications, and secure the systems.",
              ),
              _buildSectionCard(
                context: context,
                title: "4. Data Sharing & Security",
                content: "We do not sell your personal data. We only share data with authorized property agents/admins to facilitate your property search or transaction queries. Your data is protected by appropriate physical and digital security controls.",
              ),
              _buildSectionCard(
                context: context,
                title: "5. Contact Details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "For any questions, concerns, or data deletion requests, you can contact us at:",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[400], height: 1.5),
                    ),
                    SizedBox(height: 12.h),
                    _contactRow(Icons.phone_outlined, "+91 7404329180"),
                    _contactRow(Icons.email_outlined, "bandlhisarpvt.ltd@gmail.com"),
                    _contactRow(Icons.location_on_outlined, "350p, Sector 1/4, Hisar, Haryana"),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required BuildContext context, required String title, String? content, Widget? child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          SizedBox(height: 8.h),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
