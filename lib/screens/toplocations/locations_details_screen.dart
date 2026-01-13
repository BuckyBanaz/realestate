// ==================== LOCATION DETAIL SCREEN ====================
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/search/search_screen.dart';

import '../../constant/app_colors.dart';
import '../home/home_screen.dart';

class LocationDetailScreen extends StatelessWidget {
  final String locationName;
  final String rank;
  final String heroImage;
  final String subtitle;

  const LocationDetailScreen({
    Key? key,
    required this.locationName,
    required this.rank,
    required this.heroImage,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ==================== HERO HEADER ====================
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: _circleButton(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: _circleButton(
                  Icons.more_horiz_rounded,
                  () {},
                ), // Changed to more_horiz for exact match
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main Hero Image (Bali Temple with clouds)
                  Image.network(
                    "https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800",
                    fit: BoxFit.cover,
                  ),
                  // Misty Gradient Overlay (for cloudy premium feel)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // Floating Cards (No Profile - Exact Image 1 Layout)
                  Positioned(
                    top: 60,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Big Temple Card (Overlapped)
                        Transform.translate(
                          offset: const Offset(0, 20),
                          child: _floatingCard(
                            "https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800",
                            width: 140,
                            height: 180,
                            borderRadius: 28,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 120,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Right Small Temple Card (Overlapped on main)
                        Transform.translate(
                          offset: const Offset(10, 0),
                          child: _floatingCard(
                            "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800",
                            width: 100,
                            height: 120,
                            borderRadius: 24,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  // Bottom Reflection Card (Water Mirror Effect)
                  Positioned(
                    bottom: 40,
                    left: 40,
                    child: Transform.translate(
                      offset: const Offset(-20, 0),
                      child: _floatingCard(
                        "https://images.unsplash.com/photo-1578631618876-73e2d20a4448?w=800", // Reflection/water temple URL
                        width: 160,
                        height: 120,
                        borderRadius: 24,
                        // Add blur for mirror effect
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Image.network(
                              "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800", // Beach sunset URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Right Beach Card (Sunset)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Transform.translate(
                      offset: const Offset(20, 0),
                      child: _floatingCard(
                        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800", // Beach sunset URL
                        width: 90,
                        height: 80,
                        borderRadius: 20,
                      ),
                    ),
                  ),

                  // Rank Badge (#3 - Bottom Left)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        "#$rank", // e.g., "#3"
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== BODY ====================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),

                  // Search Bar
                  // Container(
                  //   height: 56,
                  //   padding: EdgeInsets.symmetric(horizontal: 16),
                  //   decoration: BoxDecoration(
                  //     color: Color(0xFFF5F7FA),
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(IconlyLight.filter, color: secondary),
                  //       SizedBox(width: 12),
                  //       Expanded(child: Text("Modern House", style: TextStyle(color: Colors.grey.shade600, fontSize: 16))),
                  //       // Icon(IconlyLight.filter, color: secondary),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 20),

                  // Found + Filters
                  // Row(
                  //   children: [
                  //     Text("Found 128 estates", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: secondary)),
                  //     Spacer(),
                  //     // _FilterChip(label: "House", icon: Icons.close, isActive: true),
                  //     // SizedBox(width: 12),
                  //     // _FilterChip(label: "₹250 - ₹450", icon: Icons.attach_money, isActive: true),
                  //   ],
                  // ),
                  // SizedBox(height: 24),
                  FeatureCard(
                    imageUrl:
                        "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
                    title: "Shree Shyam Kunj",
                    location: "Sector 15, Hisar",
                    price: "12,00,000",
                    beds: "—",
                    area: "200 sq.m",
                    tag: "Top",
                    rating: "4.8",
                  ),
                  SizedBox(height: 16),
                  FeatureCard(
                    imageUrl:
                        "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
                    title: "Shree Shyam Kunj",
                    location: "Sector 15, Hisar",
                    price: "12,00,000",
                    beds: "—",
                    area: "200 sq.m",
                    tag: "Top",
                    rating: "4.8",
                  ),
                  SizedBox(height: 16),
                  FeatureCard(
                    imageUrl:
                        "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
                    title: "Shree Shyam Kunj",
                    location: "Sector 15, Hisar",
                    price: "12,00,000",
                    beds: "—",
                    area: "200 sq.m",
                    tag: "Top",
                    rating: "4.8",
                  ),
                  SizedBox(height: 16),
                  FeatureCard(
                    imageUrl:
                        "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
                    title: "Shree Shyam Kunj",
                    location: "Sector 15, Hisar",
                    price: "12,00,000",
                    beds: "—",
                    area: "200 sq.m",
                    tag: "Top",
                    rating: "4.8",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _floatingCard(
    String imageUrl, {
    required double width,
    required double height,
    required double borderRadius,
    Widget? child, // For custom like blur
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(8, 12),
          ),
        ],
      ),
      child:
          child ??
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
    );
  }
}

// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFE8F5E8) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isActive ? primary : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) Icon(icon, size: 16, color: primary),
          if (isActive) SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? primary : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
