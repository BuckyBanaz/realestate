import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

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
          "Terms & Conditions",
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
                "Terms & Conditions",
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
                title: "1. Acceptance of Terms",
                content: "By accessing or using the B&L mobile application, you agree to comply with and be bound by these Terms and Conditions. If you do not agree to these terms, you should not access or use the application.",
              ),
              _buildSectionCard(
                context: context,
                title: "2. Account Registration",
                content: "You must provide accurate and complete details when creating an account. You are responsible for keeping your login credentials confidential and secure. B&L reserves the right to suspend accounts with fraudulent details.",
              ),
              _buildSectionCard(
                context: context,
                title: "3. Property Inquiries & Bookings",
                content: "Any property booking, enquiry, map analysis, or financial EMI calculation offered via the app is for informational purposes only. Official transactions are subject to physical verification of documents and final sign-off by B&L officials.",
              ),
              _buildSectionCard(
                context: context,
                title: "4. User Responsibilities & Prohibitions",
                content: "Users agree not to upload false information, copy list layout styles/media without permission, scrape database information, or execute unauthorized transactions or payment calls.",
              ),
              _buildSectionCard(
                context: context,
                title: "5. Contact Details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "For any questions regarding these Terms & Conditions, please contact us at:",
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
