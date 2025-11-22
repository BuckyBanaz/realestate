// lib/screens/property/property_detail_fixed.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/property/property_map_view_screen.dart';

import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../property/property_deatils_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  // Use the uploaded local file path (your environment will convert to a URL)
  final String mainImageUrl = 'assets/images/onboard_1.png';
  final String altImageUrl = '/mnt/data/e16ce833-3964-4025-82d5-8cb15dfd73a0.png';

  // Thumbnails - keep as assets or network as you like
  final List<String> thumbs = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
  ];

  PropertyDetailScreen({Key? key}) : super(key: key);

  // Helper: size helpers using MediaQuery and clamping
  double _pw(BuildContext c, double fraction) => MediaQuery.of(c).size.width * fraction;
  double _ph(BuildContext c, double fraction) => MediaQuery.of(c).size.height * fraction;
  double _clamp(double value, double minVal, double maxVal) => value.clamp(minVal, maxVal);

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap, Color? bg}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _thumbnail(String url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Image.asset(url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _thumbnailText(String text, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tagChip(IconData? icon, String txt) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.amber, size: 16),
            SizedBox(width: 6),
          ],
          Text(txt, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // compute sizes once per build
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    // Main image height derived from width to keep aspect ratio reasonable
    final double mainImageHeight = _clamp(w * 0.7, 300.0, 520.0); // keeps it from being too tall on big devices
    final double thumbSize = _clamp(w * 0.12, 48.0, 70.0); // thumbnails to right
    final double horizontalPadding = 20.0;
    final double cardRadius = 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // IMAGE STACK - bounded with padding and clamped height
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius),
                  child: Stack(
                    children: [
                      // Bounded main image using SizedBox
                      SizedBox(
                        width: double.infinity,
                        height: mainImageHeight,
                        child: Image.asset(
                          // using uploaded local path as URL (your env will transform)
                          mainImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) {
                            // fallback to alt image if network fails
                            return Image.network(
                              altImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: Colors.grey.shade300),
                            );
                          },
                        ),
                      ),

                      // Top-left back
                      Positioned(
                        top: 18,
                        left: 16,
                        child:
                        _roundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                      ),

                      // Share
                      Positioned(top: 18, right: 76, child: _roundIconButton(icon: Icons.share, onTap: () {})),

                      // Favorite
                      Positioned(top: 18, right: 18, child: _roundIconButton(icon: IconlyLight.heart, onTap: () {})),

                      // Thumbnails (right vertical)
                      Positioned(
                        bottom: 18,
                        right: 16,
                        child: Column(
                          children: [
                            _thumbnail(thumbs[0], thumbSize),
                            SizedBox(height: 10),
                            _thumbnail(thumbs[1], thumbSize),
                            SizedBox(height: 10),
                            _thumbnailText("+3", thumbSize),
                          ],
                        ),
                      ),

                      // Rating + type chip (left-bottom)
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: Row(
                          children: [
                            _tagChip(Icons.star, "4.9"),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text("Apartment", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 22),

              // Title + Price: make text sizes responsive but clamped
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
                          Text("Wings Tower",
                              style: TextStyle(
                                fontSize: _clamp(w * 0.065, 18.0, 28.0),
                                fontWeight: FontWeight.bold,
                                color: secondary
                              )),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(IconlyLight.location, size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              Expanded(child: Text("Jakarta, Indonesia", style: TextStyle(color: Colors.grey))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$ 220",
                            style: TextStyle(
                                fontSize: _clamp(w * 0.06, 16.0, 26.0), fontWeight: FontWeight.bold, color: secondary)),
                        SizedBox(height: 6),
                        Text("per month", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 16),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// RENT BUTTON (active)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        color: primary, // same green
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Rent",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    /// BUY BUTTON (inactive)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,   // same subtle off-white
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Buy",
                        style: TextStyle(
                          color: secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Spacer(),

                    /// 360 VIEW CIRCLE BUTTON
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Color(0xFFF4F3F8),   // same soft grey
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "360°",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: 20),

              // Divider
              Padding(padding: EdgeInsets.symmetric(horizontal: horizontalPadding), child: Divider(thickness: 1.0)),

              // Facilities card (kept responsive padding + sizes)
              PropertyFacilitiesSection(),

              // Map & Cost of living (responsive)
              CostOfLivingMapSection(),

              // Nearby Estates Title + grid (keeps thumbnails small)
              Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: SectionTitle(title: "Explore Nearby Estates")),
              const SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: NearbyEstatesSection()),

              SizedBox(height: 28),
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Text("Buy Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ---------------- PropertyFacilitiesSection (no big changes, but responsive)
class PropertyFacilitiesSection extends StatelessWidget {
  const PropertyFacilitiesSection({super.key});

  Widget _buildChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 20),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double avatarRadius = max(22.0, min(30.0, w * 0.07));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent header
          Row(
            children: [
              CircleAvatar(radius: avatarRadius, backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/32.jpg")),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text("Anderson", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Real Estate Agent", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ]),
              const Spacer(),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.message_outlined, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 20),

          // Chips row
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildChip(icon: Icons.bed_outlined, label: "2 Bedroom", color: cardColor),
            const SizedBox(width: 12),
            _buildChip(icon: Icons.bathtub_outlined, label: "1 Bathroom", color: cardColor),
            const SizedBox(width: 12),
            _buildChip(icon: Icons.water_drop_outlined, label: "", color: cardColor),
          ]),

          const SizedBox(height: 24),

          const Text("Location & Public Facilities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Icon(IconlyLight.location, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(child: Text("St. Ciloko Timur, Kec. Pancoran, Jakarta Selatan, Indonesia 12770", style: TextStyle(fontSize: 15))),
            ]),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(30)),
            child: Row(children: [
              Icon(Icons.near_me_outlined, color: secondary),
              const SizedBox(width: 12),
              Text("2.5 km from your location", style: TextStyle(fontSize: 15, color: Colors.black87)),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down, color: secondary),
            ]),
          ),

          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
            _NearbyFacility(icon: Icons.local_hospital_outlined, count: "2", label: "Hospital"),
            _NearbyFacility(icon: Icons.local_gas_station_outlined, count: "4", label: "Gas Stations"),
            _NearbyFacility(icon: Icons.school_outlined, count: "2", label: "Schools"),
          ]),
        ],
      ),
    );
  }
}

class _NearbyFacility extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _NearbyFacility({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: Colors.grey.shade700, size: 28),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ]),
    );
  }
}

// Cost of Living / Map Section (responsive)
class CostOfLivingMapSection extends StatelessWidget {
  const CostOfLivingMapSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mapHeight = (w * 0.48).clamp(180.0, 320.0);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
      ]),
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(children: [
            Container(
              height: mapHeight,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Image.network(
                "https://t4.ftcdn.net/jpg/03/38/37/73/360_F_338377354_1Y6oyGrvaae2kqY3YS07b6X4NDKZntne.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Center(child: CustomPaint(size: Size(double.infinity, mapHeight), painter: RoutePainter())),
            const Positioned(top: 50, left: 60, child: _MapPin(imageUrl: "https://randomuser.me/api/portraits/men/32.jpg", isAgent: true)),
            const Positioned(top: 100, right: 50, child: _MapPin(imageUrl: null, isAgent: false)),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Get.to(PropertyMapViewScreen()),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                    child: const Text("View all on map", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Cost of Living", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              TextButton(onPressed: () {}, child: Text("view details", style: TextStyle(color: secondary, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(20)),
              child: Column(children: const [
                Text("\$ 830/month", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 4),
                Text("*From average citizen spend around this location", style: TextStyle(fontSize: 13, color: Colors.grey)),
              ]),
            )
          ]),
        ),
      ]),
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
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: isAgent && imageUrl != null ? CircleAvatar(radius: 19, backgroundImage: NetworkImage(imageUrl!)) : Icon(Icons.location_city, color: secondary, size: 28),
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
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.75, size.height * 0.65);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dottedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
