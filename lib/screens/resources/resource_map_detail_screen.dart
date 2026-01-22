import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/screens/widgets/helpers.dart';

class ResourceMapDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ResourceMapDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
      body: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: CustomImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
