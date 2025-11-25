// documents_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';

/// Sample Document Model
class PropertyDocument {
  final String id;
  final String title;
  final String propertyName;
  final String docType;
  final String thumbnail; // network url or local path (/mnt/...)
  final String uploadedDate;
  final Map<String, String> metadata; // e.g., owner history, reg date, reg no, issuer, remarks

  PropertyDocument({
    required this.id,
    required this.title,
    required this.propertyName,
    required this.docType,
    required this.thumbnail,
    required this.uploadedDate,
    required this.metadata,
  });
}

class DocumentsScreen extends StatelessWidget {
  DocumentsScreen({super.key});

  // demo list — replace with real data or controller fetch
  final List<PropertyDocument> docs = [
    PropertyDocument(
      id: "doc1",
      title: "Title Deed - Plot A12",
      propertyName: "Sky Dandelions Township",
      docType: "Title Deed",
      // using your uploaded local image path as thumbnail
      thumbnail: "https://b3103330.smushcdn.com/3103330/wp-content/uploads/2016/04/mutation-procedure-transfer-of-title-of-property-in-municpality-limits-pic.jpg?lossy=2&strip=1&webp=1",
      uploadedDate: "2021-11-28",
      metadata: {
        "Registered On": "11/20/2019",
        "Registration No.": "REG-HT-001234",
        "Previous Owner": "M/s. Sunrise Builders",
        "Current Owner": "Anderson",
        "Issued By": "Hisar Land Registry",
        "Remarks": "Clear title, no encumbrance",
      },
    ),
    PropertyDocument(
      id: "doc2",
      title: "Sale Agreement - Unit 302",
      propertyName: "Urban Heights Apartment",
      docType: "Sale Agreement",
      thumbnail: "https://b3103330.smushcdn.com/3103330/wp-content/uploads/2016/04/mutation-procedure-transfer-of-title-of-property-in-municpality-limits-pic.jpg?lossy=2&strip=1&webp=1",
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
    // add more as needed
  ];

  Widget _thumbWidget(String path, {double? width, double? height}) {
    if (path.startsWith('/mnt/') || path.startsWith('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(file, width: width, height: height, fit: BoxFit.cover),
        );
      } else {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12.r)),
          child: Icon(Icons.broken_image, size: 28.w, color: Colors.grey[500]),
        );
      }
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(path, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.broken_image, size: 28.w, color: Colors.grey[500]),
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen scaffold
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Documents", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        elevation: 0,
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(IconlyLight.arrow_left_2)),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header / search if needed
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12.r)),
              child: Row(
                children: [
                  Icon(Icons.file_present_outlined, color: primary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text("Property Documents", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                  Text("${docs.length}", style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Documents list
            Expanded(
              child: ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final d = docs[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DocumentDetailScreen(document: d));
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14.r)),
                      child: Row(
                        children: [
                          Hero(tag: d.id, child: _thumbWidget(d.thumbnail, width: 110.w, height: 72.h)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 6.h),
                              Row(children: [
                                Icon(Icons.location_on, size: 12.w, color: Colors.grey),
                                SizedBox(width: 6.w),
                                Expanded(child: Text(d.propertyName, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                              ]),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: Colors.white),
                                    child: Text(d.docType, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(d.uploadedDate, style: TextStyle(color: Colors.grey[600], fontSize: 11.sp)),
                                ],
                              )
                            ]),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== Document Detail Screen ==========
class DocumentDetailScreen extends StatelessWidget {
  final PropertyDocument document;

  const DocumentDetailScreen({super.key, required this.document});

  Widget _imageWidget(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('/mnt/') || path.startsWith('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, width: width, height: height, fit: fit);
      } else {
        return Container(width: width, height: height, color: Colors.grey.shade200, child: Icon(Icons.broken_image, size: 36.w, color: Colors.grey[500]));
      }
    } else {
      return Image.network(path, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) {
        return Container(width: width, height: height, color: Colors.grey.shade200, child: Icon(Icons.broken_image, size: 36.w, color: Colors.grey[500]));
      });
    }
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140.w, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13.sp))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Document Detail", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        elevation: 0,
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(IconlyLight.arrow_left_2)),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top card with image and basic info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16.r)),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => FullscreenImageScreen(imagePath: document.thumbnail, tag: document.id));
                },
                child: Hero(tag: document.id, child: ClipRRect(borderRadius: BorderRadius.circular(12.r), child: _imageWidget(document.thumbnail, width: 140.w, height: 96.h))),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(document.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6.h),
                  Text(document.propertyName, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Row(children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: Colors.white), child: Text(document.docType, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600))),
                    SizedBox(width: 8.w),
                    Text(document.uploadedDate, style: TextStyle(color: Colors.grey[600], fontSize: 11.sp)),
                  ]),
                ]),
              )
            ]),
          ),

          SizedBox(height: 18.h),

          // Document metadata
          Text("Document Information", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12.r)),
            child: Column(children: [
              _metaRow("Registration No.", document.metadata["Registration No."] ?? "-"),
              _metaRow("Registered On", document.metadata["Registered On"] ?? "-"),
              _metaRow("Previous Owner", document.metadata["Previous Owner"] ?? "-"),
              _metaRow("Current Owner", document.metadata["Current Owner"] ?? "-"),
              _metaRow("Issued By", document.metadata["Issued By"] ?? "-"),
              _metaRow("Remarks", document.metadata["Remarks"] ?? "-"),
            ]),
          ),

          SizedBox(height: 18.h),

          // Actions: Download / Share / Open
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // implement download logic
                  // Get.snackbar("Download", "Downloading ${document.title}", snackPosition: SnackPosition.BOTTOM);
                },
                icon: Icon(Icons.download, size: 18.w,color: Colors.white,),
                label: Text("Download", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: primary, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // implement share logic
                  Get.snackbar("Share", "Share ${document.title}", snackPosition: SnackPosition.BOTTOM);
                },
                icon: Icon(Icons.share, size: 18.w),
                label: Text("Share", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
              ),
            ),
          ]),

          SizedBox(height: 16.h),

          // Full-size preview / view document
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.to(() => FullscreenImageScreen(imagePath: document.thumbnail, tag: "${document.id}-preview"));
              },
              child: Text("Open Document Preview", style: TextStyle(color: primary, fontSize: 14.sp)),
            ),
          )
        ]),
      ),
    );
  }
}

/// Reusing FullscreenImageScreen from earlier
class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String tag;

  const FullscreenImageScreen({super.key, required this.imagePath, required this.tag});

  Widget _imageWidget(String path) {
    if (path.startsWith('/mnt/') || path.startsWith('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      } else {
        return Center(child: Icon(Icons.broken_image, size: 64));
      }
    } else {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image, size: 64)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: tag,
            child: _imageWidget(imagePath),
          ),
        ),
      ),
    );
  }
}
