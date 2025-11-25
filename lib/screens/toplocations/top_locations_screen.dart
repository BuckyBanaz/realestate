import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_colors.dart';
import 'locations_details_screen.dart';

class TopLocationsScreen extends StatelessWidget {
  const TopLocationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration:  BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child:  Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: secondary,  // exact dark blue
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),

        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== TITLE + SUBTITLE ====================
            Text(
              "Top Locations",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Our recommended real estates exclusive for you.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.05,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return _LocationCard(
                    rank: loc["rank"]!,
                    title: loc["title"]!,
                    imageUrl: loc["image"]!,
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

class _LocationCard extends StatelessWidget {
  final String rank, title, imageUrl;

  const _LocationCard({
    required this.rank,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.to(LocationDetailScreen(
          locationName: title,
          rank: rank,
          heroImage: imageUrl,
          subtitle: "Our recommended real estates in $title",
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Rank Badge (Top Left)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: Text(
                  rank,
                  style:  TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: secondary,
                  ),
                ),
              ),
            ),

            // Title (Bottom Center)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
final List<Map<String, String>> locations = [
  {
    "rank": "+1",
    "title": "Sector 15, Hisar",
    "image": "assets/images/2.png",
  },
  {
    "rank": "+2",
    "title": "Hisar Cantt",
    "image": "assets/images/2.png",
  },
  {
    "rank": "+3",
    "title": "Rajguru Nagar, Hisar",
    "image": "assets/images/2.png",
  },
  {
    "rank": "+4",
    "title": "Model Town, Hisar",
    "image": "assets/images/2.png",
  },
  {
    "rank": "+5",
    "title": "Camp Chowk, Hisar",
    "image": "assets/images/2.png",
  },
  {
    "rank": "+6",
    "title": "Urban Estate II, Hisar",
    "image": "assets/images/2.png",
  },
];
