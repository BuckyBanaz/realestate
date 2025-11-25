// lib/screens/property/property_detail_fixed.dart
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/property/plot_selection_screen.dart';
import 'package:realestate/screens/property/property_equiery_form.dart';
import 'package:realestate/screens/property/property_map_view_screen.dart';

import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../property/property_deatils_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  // Use the uploaded local file path (your environment will convert to a URL)
  final String mainImageUrl = 'assets/images/Header.png';
  final String altImageUrl =
      '/mnt/data/e16ce833-3964-4025-82d5-8cb15dfd73a0.png';

  // Thumbnails - keep as assets or network as you like
  final List<String> thumbs = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
  ];

  PropertyDetailScreen({Key? key}) : super(key: key);
  double _clamp(double value, double minVal, double maxVal) =>
      value.clamp(minVal, maxVal);

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? bg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double horizontalPadding = 20.0;
    final double cardRadius = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(CupertinoIcons.back)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: Stack(
                    children: [
                       SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                           mainImageUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (ctx, err, st) {
                             return Image.network(
                              altImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  Container(color: Colors.grey.shade300),
                            );
                          },
                        ),
                      ),


                    ],
                  ),
                ),
              ),
        
              SizedBox(height: 30),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shree Shyam Kunj Phase 2",
                            style: TextStyle(
                              fontSize: _clamp(w * 0.065, 18.0, 28.0),
                              fontWeight: FontWeight.bold,
                              color: secondary,
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
                              Expanded(
                                child: Text(
                                  "Raipur Road Hisar",
                                  style: TextStyle(color: Colors.grey),
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

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Divider(thickness: 1.0),
              ),

              PropertyFacilitiesSection(),
        
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: PlotSelectionWidget(
                  onPlotSelected: (plotNo, size) {
                    print("Selected: $plotNo ($size)");
                  },
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:  ImagePreview(
                  imagePath: 'assets/images/map.jpg',
                  heroTag: 'map-1',
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                 ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => EnquiryFormScreen(
                propertyName: "Shree Shyam Kunj Phase 2",
                // propertyPrice: "₹ 22,000/month",
                propertyLocation: "Raipur Road, Hisar, Haryana",
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              "Submit Enquiry",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- PropertyFacilitiesSection (no big changes, but responsive)
class PropertyFacilitiesSection extends StatelessWidget {
  const PropertyFacilitiesSection({super.key});

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD8D8DA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 20),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: primary, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double avatarRadius = max(22.0, min(30.0, w * 0.07));

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(

              children: [
                const Text(
                  "Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F3F8), // same soft grey
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset("assets/images/360-degrees.png",fit: BoxFit.cover,height: 28,width: 28,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(IconlyLight.location, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Raipur Road, Hisar, Haryana, India, 125033",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CostOfLivingMapSection extends StatelessWidget {
  const CostOfLivingMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mapHeight = (w * 0.48).clamp(180.0, 320.0);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Container(
                  height: mapHeight,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    "https://t4.ftcdn.net/jpg/03/38/37/73/360_F_338377354_1Y6oyGrvaae2kqY3YS07b6X4NDKZntne.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: CustomPaint(
                    size: Size(double.infinity, mapHeight),
                    painter: RoutePainter(),
                  ),
                ),
                const Positioned(
                  top: 50,
                  left: 60,
                  child: _MapPin(
                    imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
                    isAgent: true,
                  ),
                ),
                const Positioned(
                  top: 100,
                  right: 50,
                  child: _MapPin(imageUrl: null, isAgent: false),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.to(PropertyMapViewScreen()),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "View all on map",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cost of Living",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "view details",
                        style: TextStyle(
                          color: secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "₹ 22,000/month",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "*From average citizen spend around this location",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Map pin
class _MapPin extends StatelessWidget {
  final String? imageUrl;
  final bool isAgent;
  const _MapPin({this.imageUrl, required this.isAgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: isAgent && imageUrl != null
            ? CircleAvatar(radius: 19, backgroundImage: NetworkImage(imageUrl!))
            : Icon(Icons.location_city, color: secondary, size: 28),
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dottedPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.75,
        size.height * 0.65,
      );

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dottedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => _FullScreenImagePage(
              imagePath: imagePath,
              heroTag: heroTag,
              fit: fit,
              maxScale: maxScale,
              minScale: minScale,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ));
        },
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: fit,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImagePage extends StatefulWidget {
  final String imagePath;
  final String heroTag;
  final BoxFit fit;
  final double maxScale;
  final double minScale;

  const _FullScreenImagePage({
    Key? key,
    required this.imagePath,
    required this.heroTag,
    required this.fit,
    required this.maxScale,
    required this.minScale,
  }) : super(key: key);

  @override
  State<_FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<_FullScreenImagePage> {
  final TransformationController _transformationController = TransformationController();

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
                  child: Image.asset(
                    widget.imagePath,
                    fit: widget.fit,
                  ),
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

