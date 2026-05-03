// transaction_detail_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';
import '../../constant/app_colors.dart';
import 'package:realestate/screens/widgets/helpers.dart';

enum PropertyType { township, plot }

class PropertyTransactionDetailScreen extends StatefulWidget {
  final String image; // network url OR local file path like /mnt/data/....
  final String title;
  final String location;
  final String tag;
  final String date;
  final Map<String, dynamic> details;
  final Map<String, dynamic> paymentDetail;
  final int? propertyId;

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
    this.propertyId,
  });

  @override
  State<PropertyTransactionDetailScreen> createState() =>
      _PropertyTransactionDetailScreenState();
}

class _PropertyTransactionDetailScreenState
    extends State<PropertyTransactionDetailScreen> {
  PropertyListItem? _remoteProperty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRemoteDetails();
  }

  Future<void> _fetchRemoteDetails() async {
    final propertyId = widget.propertyId;
    if (propertyId == null) return;
    setState(() => _isLoading = true);
    final repo = PropertyRepository();
    final details = await repo.fetchPropertyDetails(propertyId);
    if (!mounted) return;
    setState(() {
      _remoteProperty = details;
      _isLoading = false;
    });
  }

  Map<String, String>? _remoteAttributes() {
    final property = _remoteProperty;
    if (property == null) return null;
    final filtered = <String, String>{};
    filtered["Location"] = property.address.isNotEmpty
        ? property.address
        : widget.location;
    if (property.price.isNotEmpty) {
      filtered["Price"] = "₹ ${formatPrice(property.price)}";
    }
    if (property.area.isNotEmpty) {
      filtered["Area"] = property.area;
    }
    for (final attr in property.attributes) {
      final value = attr.value?.toString().trim();
      if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
        filtered[attr.attribute] = "-";
      } else {
        filtered[attr.attribute] = value;
      }
    }
    return filtered.isEmpty ? null : filtered;
  }

  String _formatDate(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty || cleaned == '-') return '-';
    final normalized = cleaned.endsWith('Z') ? cleaned : '${cleaned}Z';
    final parsed = DateTime.tryParse(normalized) ?? DateTime.tryParse(cleaned);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy, h:mm a').format(parsed.toLocal());
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
      return CustomImage(
        imageUrl: path,
        width: width,
        height: height,
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, size: 36.w, color: Colors.grey[500]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.propertyId != null && _isLoading && _remoteProperty == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final remoteAttrs = _remoteAttributes();
    final attributes = remoteAttrs ?? widget.propertyAttributes ?? {};
    
    // Check attributes for map image
    String? mapAttrUrl;
    if (_remoteProperty != null) {
      final mapAttr = _remoteProperty!.attributes.firstWhereOrNull((a) => a.attribute.toLowerCase().contains("map") || a.attribute.toLowerCase().contains("plan"));
      mapAttrUrl = mapAttr?.value;
    }

    final effectiveMapImage = mapAttrUrl ?? (widget.mapImage ?? '');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        actions: [
          // IconButton(
          //   onPressed: () => Get.to(
          //     DocumentDetailScreen(
          //       owner: OwnerDocumentGroup(
          //         ownerId: 74,
          //         name: "Himanshu Kumawat",
          //         email: "sssssdddd@gmail.com",
          //         phone: "1234567890",
          //         address: "kazipura",
          //         documents: [],
          //       ),
          //       doc: DocumentItem(
          //         id: 8,
          //         documentName: "Sale Agreement - Unit 302",
          //         documentUrl: "http://108.181.185.27/bladmin/public/uploads/documents/1768568662_WhatsApp Image 2026-01-16 at 10.37.20 AM.jpeg",
          //       ),
          //     ),
          //   ),
          //   icon: Icon(IconlyLight.document),
          // ),
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
                  () => FullscreenImageScreen(
                    imagePath: widget.image,
                    tag: widget.title,
                  ),
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
                        tag: widget.title,
                        child: _imageWidget(
                          widget.image,
                          width: 130.w,
                          height: 96.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
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
                                  widget.location,
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
                                  widget.tag,
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                              // SizedBox(width: 8.w),
                              // if (effective360 != null)
                              //   OutlinedButton.icon(
                              //     onPressed: () {
                              //       // open 360 view (placeholder)
                              //       ScaffoldMessenger.of(context).showSnackBar(
                              //         SnackBar(
                              //           content: Text(
                              //             "360 View: Open 360 viewer: $effective360",
                              //           ),
                              //           behavior: SnackBarBehavior.floating,
                              //         ),
                              //       );
                              //     },
                              //     icon: Icon(Icons.threed_rotation, size: 16.w),
                              //     label: Text(
                              //       "360",
                              //       style: TextStyle(fontSize: 12.sp),
                              //     ),
                              //     style: OutlinedButton.styleFrom(
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(12.r),
                              //       ),
                              //     ),
                              //   ),
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
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 10.h),
            // _detailTile(context, "Check in", details["checkIn"] ?? "-"),
            // _detailTile(context, "Check out", details["checkOut"] ?? "-"),
            _detailTile(context, "Owner name", widget.details["owner"] ?? "-"),
            _detailTile(context, "Transaction type", widget.tag),
            _detailTile(
              context,
              "Transaction Date",
              _formatDate(widget.date),
            ),

            SizedBox(height: 20.h),

            // ---------------- PROPERTY ATTRIBUTES (dynamic) ----------------
            Text(
              "Property Details",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
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
            if (effectiveMapImage.isNotEmpty)
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
                        Get.to(
                          () => FullscreenImageScreen(
                            imagePath: effectiveMapImage,
                            tag: "map-${widget.title}",
                          ),
                        );
                      },
                      child: Container(
                        height: 160.h,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: _imageWidget(effectiveMapImage),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),

            SizedBox(height: 8.h),

            // ---------------- PAYMENT DETAILS ----------------
            // Text(
            //   "Payment Detail",
            //   style: TextStyle(
            //     fontSize: 15.sp,
            //     fontWeight: FontWeight.w700,
            //     color: Theme.of(context).textTheme.bodyLarge?.color,
            //   ),
            // ),
            // SizedBox(height: 12.h),
            // Container(
            //   padding: EdgeInsets.all(16.w),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).cardColor,
            //     borderRadius: BorderRadius.circular(16.r),
            //   ),
            //   child: Column(
            //     children: [
            //       _detailTile(
            //         context,
            //         "Period time",
            //         paymentDetail["period"] ?? "-",
            //       ),
            //       _detailTile(
            //         context,
            //         "Total Amount",
            //         "₹ ${formatPrice(paymentDetail["total"])}",
            //       ),
            //       _detailTile(
            //         context,
            //         "Monthly payment",
            //         "₹ ${formatPrice(paymentDetail["monthly"])}",
            //       ),
            //       _detailTile(
            //         context,
            //         "Paid Amount",
            //         "₹ ${formatPrice(paymentDetail["paid"])}",
            //       ),
            //       _detailTile(
            //         context,
            //         "Balance Amount",
            //         "₹ ${formatPrice(paymentDetail["balance"])}",
            //       ),
            //       _detailTile(
            //         context,
            //         "Discount",
            //         "₹ ${formatPrice(paymentDetail["discount"])}",
            //       ),
            //       Divider(),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             "Net Payable",
            //             style: TextStyle(
            //               fontSize: 16.sp,
            //               fontWeight: FontWeight.bold,
            //               color: Theme.of(context).textTheme.bodyLarge?.color,
            //             ),
            //           ),
            //           Text(
            //             "₹ ${formatPrice(paymentDetail["total"])}",
            //             style: TextStyle(
            //               fontSize: 16.sp,
            //               color: primary,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // SizedBox(height: 20.h),

            // // ---------------- PAYMENT METHOD ----------------
            // Text(
            //   "Payment Method",
            //   style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            // ),
            // SizedBox(height: 10.h),
            // Container(
            //   padding: EdgeInsets.all(12.w),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12.r),
            //     border: Border.all(color: Colors.grey.shade300),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(Icons.email_outlined, color: Colors.grey),
            //       SizedBox(width: 10.w),
            //       Text(
            //         details["paymentEmail"] ?? "•••••••@gmail.com",
            //         style: TextStyle(fontSize: 13.sp),
            //       ),
            //     ],
            //   ),
            // ),

            // SizedBox(height: 25.h),

            // // ---------------- ADD REVIEW BUTTON ----------------
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: primary,
            //       padding: EdgeInsets.symmetric(vertical: 14.h),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(16.r),
            //       ),
            //     ),
            //     onPressed: () {
            //       // open review flow
            //       // Get.snackbar("Review", "Open review flow", snackPosition: SnackPosition.BOTTOM);
            //     },
            //     child: Text(
            //       "Click here to make payment ",
            //       style: TextStyle(
            //         fontSize: 15.sp,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
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
      return CustomImage(imageUrl: path);
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
