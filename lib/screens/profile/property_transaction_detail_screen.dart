// transaction_detail_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/profile/documents_screen.dart';
import '../../constant/app_colors.dart';

enum PropertyType { township, plot }

class PropertyTransactionDetailScreen extends StatelessWidget {
  final String image; // network url OR local file path like /mnt/data/....
  final String title;
  final String location;
  final String tag;
  final String date;
  final Map<String, dynamic> details;
  final Map<String, dynamic> paymentDetail;

  // New params for property-specific attributes
  final PropertyType propertyType;
  final Map<String, String>? propertyAttributes; // optional custom attributes
  final String? mapImage; // network url or local file path
  final String? view360Url; // optional 360 view url or id

  const PropertyTransactionDetailScreen({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.tag,
    required this.date,
    required this.details,
    required this.paymentDetail,
    this.propertyType = PropertyType.township,
    this.propertyAttributes,
    this.mapImage,
    this.view360Url,
  });

  // default attributes for township
  Map<String, String> _defaultTownshipAttributes() {
    return {
      "Location": location,
      "Total Land Area": "120 acres",
      "Plot / Unit Size": "30×50 ft (typical)",
      "Road Width (Internal)": "9 - 12 m",
      "Zoning / Land Use": "Residential / Mixed-use",
      "Legal Status & Approvals": "Approved",
      "Connectivity": "2 km to market, 1.5 km to school",
      "Price / Rate": "₹ 800 / sq.ft",
      "Facing": "North / East (varies)",
    };
  }

  // default attributes for plot
  Map<String, String> _defaultPlotAttributes() {
    return {
      "Location": location,
      "Plot Size / Area": "3000 sq.ft",
      "Plot Shape": "Rectangle",
      "Dimensions": "60 × 50 ft",
      "Facing / Orientation": "North-facing",
      "Zoning Type": "Residential",
      "Access Road Width": "10 m",
      "Surroundings": "Park to the east, School to the north",
    };
  }

  Widget _imageWidget(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: Icon(Icons.photo, size: 36.w, color: Colors.grey[500]),
      );
    }
    // local file (from notebook path) -> starts with /mnt/
    if (path.startsWith('/mnt/') || path.startsWith('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, width: width, height: height, fit: fit);
      } else {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, size: 36.w, color: Colors.grey[500]),
        );
      }
    } else {
      // network
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, size: 36.w, color: Colors.grey[500]),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attributes =
        propertyAttributes ??
        (propertyType == PropertyType.township
            ? _defaultTownshipAttributes()
            : _defaultPlotAttributes());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        actions: [
          IconButton(
            onPressed: () => Get.to(
              DocumentDetailScreen(
                document: PropertyDocument(
                  id: "doc2",
                  title: "Sale Agreement - Unit 302",
                  propertyName: "Plot No. 21 Shree Shyam Kunj Phase 5",
                  docType: "Sale Agreement",
                  thumbnail:
                      "https://b3103330.smushcdn.com/3103330/wp-content/uploads/2016/04/mutation-procedure-transfer-of-title-of-property-in-municpality-limits-pic.jpg?lossy=2&strip=1&webp=1",
                  uploadedDate: "2022-05-14",
                  metadata: {
                    "Registered On": "05/10/2022",
                    "Registration No.": "REG-UH-00421",
                    "Previous Owner": "Mr. Ramesh",
                    "Current Owner": "Chetan Sharma",
                    "Issued By": "District Registrar",
                    "Remarks": "Standard sale agreement",
                  },
                ),
              ),
            ),
            icon: Icon(IconlyLight.document),
          ),
        ],
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrow_left_2),
        ),
        title: Text(
          "Property Detail",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TOP CARD with HERO ----------
            GestureDetector(
              onTap: () {
                // open fullscreen preview
                Get.to(
                  () => FullscreenImageScreen(imagePath: image, tag: title),
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Theme.of(context).cardColor,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Hero(
                        tag: title,
                        child: _imageWidget(image, width: 130.w, height: 96.h),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.w,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  color: primary.withOpacity(0.15),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (view360Url != null)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // open 360 view (placeholder)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("360 View: Open 360 viewer: $view360Url"),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.threed_rotation, size: 16.w),
                                  label: Text(
                                    "360",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // ------------------ TRANSACTION DETAILS ------------------
            Text(
              "Transaction Detail",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 10.h),
            _detailTile(context, "Check in", details["checkIn"] ?? "-"),
            _detailTile(context, "Check out", details["checkOut"] ?? "-"),
            _detailTile(context, "Owner name", details["owner"] ?? "-"),
            _detailTile(context, "Transaction type", tag),
            _detailTile(context, "Transaction Date", date),

            SizedBox(height: 20.h),

            // ---------------- PROPERTY ATTRIBUTES (dynamic) ----------------
            Text(
              "Property Details",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 10.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: attributes.entries.map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            e.key,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            e.value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 12.h),

            // Map preview + button
            if ((mapImage ?? "").isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Map",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: GestureDetector(
                      onTap: () {
                        if ((mapImage ?? "").startsWith('/mnt') ||
                            (mapImage ?? "").startsWith('/data')) {
                          Get.to(
                            () => FullscreenImageScreen(
                              imagePath: mapImage!,
                              tag: "map-$title",
                            ),
                          );
                        } else {
                          Get.to(
                            () => FullscreenImageScreen(
                              imagePath: mapImage!,
                              tag: "map-$title",
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 160.h,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: _imageWidget(mapImage!),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),

            SizedBox(height: 8.h),

            // ---------------- PAYMENT DETAILS ----------------
            Text(
              "Payment Detail",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _detailTile(context, "Period time", paymentDetail["period"] ?? "-"),
                  _detailTile(
                    context,
                    "Monthly payment",
                    "₹ ${paymentDetail["monthly"] ?? '-'}",
                  ),
                  _detailTile(
                    context,
                    "Discount",
                    "₹ ${paymentDetail["discount"] ?? '0'}",
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        "₹ ${paymentDetail["total"] ?? '0'}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ---------------- PAYMENT METHOD ----------------
            Text(
              "Payment Method",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.grey),
                  SizedBox(width: 10.w),
                  Text(
                    details["paymentEmail"] ?? "•••••••@gmail.com",
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25.h),

            // ---------------- ADD REVIEW BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () {
                  // open review flow
                  // Get.snackbar("Review", "Open review flow", snackPosition: SnackPosition.BOTTOM);
                },
                child: Text(
                  "Click here to make payment ",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen image preview screen (for hero tap)
class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String tag;

  const FullscreenImageScreen({
    super.key,
    required this.imagePath,
    required this.tag,
  });

  Widget _imageWidget(String path) {
    if (path.startsWith('/mnt/') || path.startsWith('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      } else {
        return Center(child: Icon(Icons.broken_image, size: 64));
      }
    } else {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Center(child: Icon(Icons.broken_image, size: 64)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(tag: tag, child: _imageWidget(imagePath)),
        ),
      ),
    );
  }
}
