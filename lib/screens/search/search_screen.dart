import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';

import '../home/home_screen.dart';
import '../home/modules/featured_properties_list.dart';
import '../property/property_deatils_screen.dart';

import 'package:realestate/data/controllers/search_controller.dart';
import 'package:realestate/data/models/estate_model.dart';

// ====================== REST OF IMPORTS ARE ABOVE ======================

// ====================== MAIN SEARCH SCREEN ======================
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchController());

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(CupertinoIcons.back)),
        title: const Text("Search results", style: TextStyle(color: Colors.black87, fontSize: 18)),
        // actions: [
        //   // IconButton(onPressed: () {}, icon: const Icon(IconlyLight.search, color: Colors.black87)),
        //   IconButton(
        //     icon: const Icon(IconlyLight.filter, color: Colors.black87),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Optional Search Bar if you want it here
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Search houses, apartments... ',
                  prefixIcon: const Icon(IconlyLight.search),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),

            // Results (uses LayoutBuilder to avoid unbounded constraints)
            Expanded(child: ResultsSection(controller: controller)),
          ],
        ),
      ),
    );
  }
}

// ====================== RESULTS OR EMPTY STATE (Fixed) ======================
class ResultsSection extends StatelessWidget {
  final SearchController controller;
  const ResultsSection({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = nearbyEstates;

      // If searching and nothing found -> show empty state
      if (controller.searchQuery.value.isNotEmpty && results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_off_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text("Search not found", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  "Sorry we can't find the real estate you are looking for. Maybe, a little spelling mistake?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                ),
              ),
            ],
          ),
        );
      }

      // Default state + results
      // inside ResultsSection.build(...)
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      "Found ${results.length} estates",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: secondary),
                    ),
                    // const Spacer(),
                    // _filterChip("House", true),
                    // const SizedBox(width: 8),
                    // _filterChip("₹50 - ₹250", false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: results.length,
                  itemBuilder: (ctx, i) {
                    final e = results[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FeatureCard(
                        imageUrl: e['image']!,
                        title: e['title']!,
                        location: e['location']!,
                        price: e['price']!,
                        beds: e['beds']!,
                        area: e['area']!,
                        tag: e['tag']!,
                        rating: e['rating']!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      });

    });
  }

  Widget _filterChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? secondary : cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.grey[700],
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.location,
  }) : super(key: key);

  final String name, rating, location;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    final cardHeight = (screenW * 0.24).clamp(88.0, 150.0);
    final imageWidth = (screenW * 0.30).clamp(90.0, 130.0);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade200
          ),
      ),
      child: Row(
        children: [
          // IMAGE
          SizedBox(
            width: imageWidth,
            height: cardHeight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/1.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

