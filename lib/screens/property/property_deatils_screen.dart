// lib/screens/property/property_detail_fixed.dart
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/property/property_deatils_screen.dart';
import 'package:realestate/screens/property/property_equiery_form.dart';
import 'package:realestate/screens/property/property_map_view_screen.dart';
import 'package:realestate/screens/property/plot_selection_screen.dart';
import 'package:realestate/Routes/appRoutes.dart';

/// Improved PropertyDetailScreen with:
/// - better gallery (main image + thumbnails)
/// - Property Details card (all requested attributes)
/// - 360 view and map preview
/// - Styled consistent plot cards maintained below
class PropertyDetailScreen extends StatelessWidget {
  // local assets or network fallback
  final String mainImageUrl = 'assets/images/Header.png';
  final String altImageUrl =
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200';

  final List<String> thumbs = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
  ];

  PropertyDetailScreen({Key? key}) : super(key: key);

  Widget _iconCircle(BuildContext context, IconData icon, {Color bg = Colors.white}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 18.0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(IconlyLight.heart, color: Theme.of(context).iconTheme.color),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ---------- Gallery (main image + vertical thumbs) ----------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 6,
                ),
                child: _Gallery(
                  mainImagePath: mainImageUrl,
                  altImage: altImageUrl,
                  thumbs: thumbs,
                ),
              ),

              SizedBox(height: 18),

              // Title + Location
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shree Shyam Kunj Phase 2",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                IconlyLight.location,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "Raipur Road, Hisar, Haryana",
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // small actions
                    Column(
                      children: [
                        _iconCircle(context, Icons.share),
                        SizedBox(height: 8),
                        _iconCircle(context, IconlyLight.download),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14),

              // ---------- Details Card (attributes) ----------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: PropertyDetailsSection(
                  details: {
                    "Plot Key": "Shree Shyam Kunj — Plot No. 5",
                    "Location": "Raipur Road, Hisar, Haryana, 125033",
                    "Plot Size / Area": "30×50 ft (150 sq yd)",
                    "Plot Shape": "Rectangular",
                    "Dimensions": "30 × 50 ft",
                    "Facing / Orientation": "East Facing",
                    "Zoning Type": "Residential",
                    "Access Road Width": "30 ft wide internal road",
                    "Surroundings": "Park on east, main road on north",
                    "360 View": "Available",
                    "Map Image": "https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg?mbid=social_retweet", // local asset preview
                  },
                ),
              ),

              SizedBox(height: 18),

              // ---------- Plot selection (existing widget) ----------


              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Plots",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),

                    PlotSelectionWidget(
                      onPlotSelected: (plotNo, size) {
                        Get.snackbar(
                          "Selected",
                          "$plotNo • $size",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),

                  ],
                ),
              ),

              SizedBox(height: 18),

              // // Map preview
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text("Site Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              //       SizedBox(height: 10),
              //       GestureDetector(
              //         onTap: () => Get.to(() => PropertyMapViewScreen()),
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(12),
              //           child: Image.asset(
              //             'assets/images/map.jpg',
              //             height: 180,
              //             width: double.infinity,
              //             fit: BoxFit.cover,
              //             errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey.shade200),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Site Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                         color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    ImagePreview(
                      imagePath: 'assets/images/map.jpg',
                      heroTag: 'map-1',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.enquiry,
                arguments: {
                  'propertyName': "Shree Shyam Kunj Phase 2",
                  'propertyLocation': "Raipur Road, Hisar, Haryana",
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Submit Enquiry",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Gallery Widget --------------------
class _Gallery extends StatefulWidget {
  final String mainImagePath;
  final String altImage;
  final List<String> thumbs;

  const _Gallery({
    Key? key,
    required this.mainImagePath,
    required this.altImage,
    required this.thumbs,
  }) : super(key: key);

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  String? _current;
  @override
  void initState() {
    super.initState();
    _current = widget.mainImagePath;
  }

  void _openPreview(String image) {
    Get.to(
      () => _FullScreenImagePage(imagePath: image),
      opaque: false,
      transition: Transition.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double galleryHeight = 240;
    final thumbSize = 72.0;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openPreview(_current ?? widget.altImage),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _imageWidget(
                  _current ?? widget.altImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.thumbs.map((t) {
            final isSelected = t == _current;
            return GestureDetector(
              onTap: () => setState(() => _current = t),
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _imageWidget(t, fit: BoxFit.cover),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _imageWidget(String path, {BoxFit fit = BoxFit.cover}) {
    // prefer asset if path starts with assets, else network
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
      );
    } else {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
      );
    }
  }
}

// -------------------- Property Details Section --------------------
class PropertyDetailsSection extends StatelessWidget {
  final Map<String, String> details;

  const PropertyDetailsSection({Key? key, required this.details})
    : super(key: key);

  Widget _row(BuildContext context, String title, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build a card with all attributes
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.grey.shade200
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row with title and 360 button
            Row(
              children: [
                Text(
                  "Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                Spacer(),
                if (details.containsKey("360 View") &&
                    details["360 View"]!.toLowerCase() == "available")
                  ElevatedButton.icon(
                    onPressed: () {
                      // open 360 view — replace with real implementation
                      // Get.snackbar(
                      //   "360",
                      //   "Opening 360° view...",
                      //   snackPosition: SnackPosition.BOTTOM,
                      // );
                    },
                    icon: Icon(Icons.threesixty, size: 18),
                    label: Text("360°"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),

            // location row in a small rounded box
            if (details.containsKey("Location"))
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(IconlyLight.location, color: Colors.grey),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        details["Location"]!,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.map_outlined, color: Theme.of(context).iconTheme.color),
                      onPressed: () => Get.toNamed(AppRoutes.propertyMap),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 12),

            // details list
            _row(context, "Plot Key Property Attributes", details["Plot Key"] ?? "-"),
            _row(context, "Plot Size / Area", details["Plot Size / Area"] ?? "-"),
            _row(context, "Plot Shape", details["Plot Shape"] ?? "-"),
            _row(context, "Dimensions (L × W)", details["Dimensions"] ?? "-"),
            _row(
              context,
              "Facing / Orientation",
              details["Facing / Orientation"] ?? "-",
            ),
            _row(context, "Zoning Type", details["Zoning Type"] ?? "-"),
            _row(context, "Access Road Width", details["Access Road Width"] ?? "-"),
            _row(context, "Surroundings / Neighborhood", details["Surroundings"] ?? "-"),

            SizedBox(height: 8),

            // map thumbnail row
            if (details.containsKey("Map Image"))
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.propertyMap),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      details["Map Image"]!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(height: 120, color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Full screen image viewer (simpler) -----------------
class _FullScreenImagePage extends StatelessWidget {
  final String imagePath;
  const _FullScreenImagePage({Key? key, required this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imagePath.startsWith('assets/')) {
      child = Image.asset(imagePath, fit: BoxFit.contain);
    } else {
      child = Image.network(imagePath, fit: BoxFit.contain);
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: child)),
            Positioned(
              top: 20,
              left: 16,
              child: BackButton(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String imagePath;
  final String heroTag;
  final EdgeInsetsGeometry? padding;
  final BoxFit fit;
  final double maxScale;
  final double minScale;

  const ImagePreview({
    Key? key,
    required this.imagePath,
    required this.heroTag,
    this.padding,
    this.fit = BoxFit.contain,
    this.maxScale = 4.0,
    this.minScale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => _ImageScreenImagePage(
                imagePath: imagePath,
                heroTag: heroTag,
                fit: fit,
                maxScale: maxScale,
                minScale: minScale,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imagePath, fit: fit),
          ),
        ),
      ),
    );
  }
}

class _ImageScreenImagePage extends StatefulWidget {
  final String imagePath;
  final String heroTag;
  final BoxFit fit;
  final double maxScale;
  final double minScale;

  const _ImageScreenImagePage({
    Key? key,
    required this.imagePath,
    required this.heroTag,
    required this.fit,
    required this.maxScale,
    required this.minScale,
  }) : super(key: key);

  @override
  State<_ImageScreenImagePage> createState() => _ImageScreenImagePageState();
}

class _ImageScreenImagePageState extends State<_ImageScreenImagePage> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetAndPop() {
    final matrix = _transformationController.value;
    final isIdentity = matrix == Matrix4.identity();

    if (isIdentity) {
      Navigator.of(context).pop();
      return;
    }
    final animationController = AnimationController(
      vsync: NavigatorState(),
      duration: const Duration(milliseconds: 200),
    );
    _transformationController.value = Matrix4.identity();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.heroTag,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  clipBehavior: Clip.none,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: widget.minScale,
                  maxScale: widget.maxScale,
                  child: Image.asset(widget.imagePath, fit: widget.fit),
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (_transformationController.value == Matrix4.identity()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
