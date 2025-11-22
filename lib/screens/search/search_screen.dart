import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';

import '../home/home_screen.dart';
import '../property/property_deatils_screen.dart';

// ====================== CONTROLLER ======================
class SearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var searchQuery = "".obs;

  final List<EstateModel> dummyEstates = [
    EstateModel("Bridgeland Modern House", "4.8", "Semarang", "260", "House"),
    EstateModel("Wayside Modern House", "4.9", "Jakarta", "220", "House"),
    EstateModel("Shoolview House", "4.7", "Bandung", "245", "Villa"),
    EstateModel("Palm Spring Villa", "5.0", "Bali", "380", "Villa"),
    EstateModel("Skyline Apartment", "4.6", "Surabaya", "180", "Apartment"),
    EstateModel("Greenwood Residence", "4.9", "Yogyakarta", "310", "Villa"),
    EstateModel("Urban Loft", "4.5", "Medan", "190", "Apartment"),
  ];

  List<EstateModel> get filteredEstates {
    if (searchQuery.value.isEmpty) return dummyEstates;
    return dummyEstates
        .where((e) => e.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}

class EstateModel {
  final String name, rating, location, price, tag;
  EstateModel(this.name, this.rating, this.location, this.price, this.tag);
}

// ====================== MAIN SEARCH SCREEN ======================
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Search results", style: TextStyle(color: Colors.black87, fontSize: 18)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(IconlyLight.search, color: Colors.black87)),
          IconButton(
            icon: const Icon(IconlyLight.filter, color: Colors.black87),
            onPressed: () {},
          ),
        ],
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
      final results = controller.filteredEstates;

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
                    const Spacer(),
                    _filterChip("House", true),
                    const SizedBox(width: 8),
                    _filterChip("\$50 - \$250", false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: results.length,
                  itemBuilder: (ctx, i) {
                    final estate = results[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ResultCard(
                        name: estate.name,
                        rating: estate.rating,
                        location: estate.location,
                        price: estate.price,
                        tag: estate.tag,
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
    required this.price,
    required this.tag,
  }) : super(key: key);

  final String name, rating, location, price, tag;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    // card height proportional to screen width
    final cardHeight = (screenW * 0.24).clamp(92.0, 160.0);
    // image area takes ~30% of width but clamped so it never becomes too wide
    final imageWidth = (screenW * 0.30).clamp(90.0, 140.0);

    return GestureDetector(
      onTap: () => Get.to(PropertyDetailScreen()),
      child: Container(
        width: double.infinity,
        height: cardHeight,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // LEFT: bounded image inside a SizedBox (prevents infinite width)
            SizedBox(
              width: imageWidth,
              height: cardHeight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/1.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),

            // RIGHT: Expanded content takes remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title + phone icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: secondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E8), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.phone_outlined, size: 16, color: secondary),
                        ),
                      ],
                    ),

                    // Rating + location
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "($location)",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$$price/month", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: secondary)),
                        TextButton.icon(
                          onPressed: () => Get.to(PropertyDetailScreen()),
                          icon: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                          label: const Text(
                            "Details",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
