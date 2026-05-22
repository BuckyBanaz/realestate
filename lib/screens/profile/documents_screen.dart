import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constant/app_colors.dart';
import '../../data/controllers/document_controller.dart';
import '../../data/models/owner_document_model.dart';
import '../widgets/helpers.dart';

class DocumentsScreen extends StatelessWidget {
  DocumentsScreen({super.key});

  final DocumentController controller = Get.put(DocumentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Documents",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: scaffoldColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: secondary,
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Card
              Obx(() => Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(IconlyBold.document, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Safe Repository",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            controller.isLoading.value 
                              ? "Scanning vault..." 
                              : "${controller.documentGroups.fold(0, (sum, group) => sum + group.documents.length)} Documents Secured",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0)),
              
              SizedBox(height: 24.h),

              Text(
                "VERIFIED DOCUMENTS",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ).paddingOnly(left: 4.w),
              
              SizedBox(height: 16.h),

              // List of Documents
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (_, __) => const DocumentShimmer(),
                    );
                  }

                  if (controller.documentGroups.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Flatten groups for internal listing or show by owner
                  final allDocuments = <Map<String, dynamic>>[];
                  for (var group in controller.documentGroups) {
                    for (var doc in group.documents) {
                      allDocuments.add({
                        'owner': group,
                        'doc': doc
                      });
                    }
                  }

                  return ListView.separated(
                    itemCount: allDocuments.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = allDocuments[index];
                      final OwnerDocumentGroup owner = item['owner'];
                      final DocumentItem doc = item['doc'];

                      return _buildDocumentCard(owner, doc, index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(IconlyLight.document, size: 64.sp, color: Colors.grey.withOpacity(0.2)),
          ),
          SizedBox(height: 24.h),
          Text(
            "No documents found",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your verified property documents will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildDocumentCard(OwnerDocumentGroup owner, DocumentItem doc, int index) {
    return GestureDetector(
      onTap: () => Get.to(() => DocumentDetailScreen(owner: owner, doc: doc)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Document Icon / Thumbnail
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(
                  _getDocIcon(doc.documentName),
                  color: secondary,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.documentName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Owner: ${owner.name}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Arrow
            Icon(IconlyLight.arrow_right_2, color: Colors.white.withOpacity(0.3), size: 18.sp),
          ],
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0),
    );
  }

  IconData _getDocIcon(String name) {
    if (name.toLowerCase().contains('deed') || name.toLowerCase().contains('title')) {
      return Icons.assignment_turned_in_rounded;
    } else if (name.toLowerCase().contains('agreement')) {
      return Icons.handshake_rounded;
    } else if (name.toLowerCase().contains('tax')) {
      return Icons.receipt_long_rounded;
    }
    return Icons.description_rounded;
  }
}

// ========== Document Detail Screen ==========
class DocumentDetailScreen extends StatelessWidget {
  final OwnerDocumentGroup owner;
  final DocumentItem doc;

  const DocumentDetailScreen({super.key, required this.owner, required this.doc});

  Future<void> _downloadDocument(BuildContext context) async {
    final url = doc.documentUrl.trim();
    if (url.isEmpty) {
      showCustomToast("Document URL missing", isError: true);
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showCustomToast("Could not open document link", isError: true);
      }
    } catch (e) {
      showCustomToast("Download failed", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text("Document Details", 
          style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon( Icons.arrow_back_ios_new_rounded, color: Colors.white)),
        backgroundColor: scaffoldColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Preview Card
            Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Stack(
                  children: [
                    CustomImage(
                      imageUrl: doc.documentUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: GestureDetector(
                        onTap: () => Get.to(() => FullscreenImageScreen(imagePath: doc.documentUrl, tag: "doc-${doc.id}")),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(IconlyLight.scan, color: Colors.white, size: 20.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

            SizedBox(height: 30.h),

            // Document Info
            Text("DOCUMENT INFORMATION", 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  _infoRow("Document Name", doc.documentName),
                  _divider(),
                  _infoRow("Registration ID", "REG-${doc.id}8827"),
                  _divider(),
                  _infoRow("Date Uploaded", "16 Jan 2026"),
                  _divider(),
                  _infoRow("Status", "Verified", valueColor: Colors.green),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            SizedBox(height: 24.h),

            // Owner Info
            Text("OWNER DETAILS", 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  _infoRow("Full Name", owner.name),
                  _divider(),
                  _infoRow("Email", owner.email),
                  _divider(),
                  _infoRow("Phone", owner.phone),
                  _divider(),
                  _infoRow("Address", owner.address),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            SizedBox(height: 32.h),

            // Action Button
            /*
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: () => _downloadDocument(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                  elevation: 0,
                ),
                icon: const Icon(IconlyLight.download, color: Colors.white),
                label: Text("Download Document", 
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.white)),
              ),
            ).animate().fadeIn(delay: 600.ms),
            */
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120.w, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp))),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right, 
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, 
              fontSize: 13.sp, 
              color: valueColor ?? Colors.white
            )
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      color: Colors.white.withOpacity(0.05),
    );
  }
}

class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;
  final String tag;

  const FullscreenImageScreen({super.key, required this.imagePath, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white)),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            child: CustomImage(
              imageUrl: imagePath,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// Simple Shimmer for Document items
class DocumentShimmer extends StatelessWidget {
  const DocumentShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 150.w, height: 12.h, color: Colors.white.withOpacity(0.05)),
                SizedBox(height: 8.h),
                Container(width: 100.w, height: 10.h, color: Colors.white.withOpacity(0.05)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
