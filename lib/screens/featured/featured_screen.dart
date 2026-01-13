import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/search/search_screen.dart';

import '../home/home_screen.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon:  Icon(IconlyLight.filter, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==================== HERO IMAGE GALLERY ====================
            _buildStaggeredHeroGallery(context),

            const SizedBox(height: 24),

            // ==================== TITLE + SUBTITLE ====================
             Text(
              "Featured Estates",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Our recommended real estates exclusive for you.",
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 24),

            // ==================== SEARCH BAR ====================
            const SearchTextField(), // jo tune pehle manga tha
            const SizedBox(height: 20),

            // ==================== ESTATES COUNT BADGE ====================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "70 estates",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon:  Icon(IconlyLight.filter_2,color: Theme.of(context).iconTheme.color,),
                  onPressed: () {},
                ),
                IconButton(
                  icon:  Icon(Icons.grid_view,color: Theme.of(context).iconTheme.color,),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================== LIST OF ESTATES (tera card use kiya) ====================
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final data = estatesData[index % estatesData.length];
                return FeatureCard(
                  imageUrl: data["image"]!,
                  title: data["name"]!,
                  rating: data["rating"]!,
                  location: data["loc"]!,
                  price: data["price"]!,
                  tag: data["tag"]!,
                  beds: data["beds"]!,
                  area: data["area"]!,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  // Replace pura hero section with this
  Widget _buildStaggeredHeroGallery(BuildContext context) {
    // use the uploaded file path (env will convert to a reachable URL)
    const String mainImageUrl = 'assets/images/2.png';

    // thumbs can be assets or other uploaded paths
    const String thumb1 = 'assets/images/2.png';
    const String thumb2 = 'assets/images/3.png';
    const String bottomImg = 'assets/images/4.png';

    final double screenW = MediaQuery.of(context).size.width;
    final double pad = 20.0;
    final double totalW = screenW - pad * 2;

    // proportional sizes with clamps
    final double leftW = (totalW * 0.60).clamp(180.0, 420.0);
    final double rightW = (totalW - leftW - 12).clamp(110.0, 260.0);
    final double topLeftH = (leftW * 0.68).clamp(160.0, 340.0);
    final double topRightH = (rightW * 0.62).clamp(110.0, 220.0);
    final double bottomH = (totalW * 0.42).clamp(140.0, 300.0);

    // container height enough to fit everything (allow overlap)
    final double containerH = topLeftH + 12 + bottomH * 0.45;

    final BorderRadius bigR = BorderRadius.circular(18);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: SizedBox(
        height: containerH,
        child: Stack(
          clipBehavior: Clip.none, // important to allow overlap outside bounds
          children: [
            // 1) BOTTOM image first -> painted below
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: bottomH,
                decoration: BoxDecoration(
                  borderRadius: bigR,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 18, offset: Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: bigR,
                  child: Image.asset(
                    bottomImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: bottomH,
                  ),
                ),
              ),
            ),

            // 2) TOP-LEFT main image (placed after bottom so it paints above)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: leftW,
                height: topLeftH,
                decoration: BoxDecoration(
                  borderRadius: bigR,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: bigR,
                  child: Image.asset(
                    mainImageUrl,
                    fit: BoxFit.cover,
                    width: leftW,
                    height: topLeftH,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),

            // 3) TOP-RIGHT stacked small thumbnails (on top — keep them last)
            Positioned(
              top: topLeftH * 0.14, // slight vertical offset to make it staggered
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // small top thumbnail
                  Container(
                    width: rightW,
                    height: topRightH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 14, offset: Offset(0, 8))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(thumb1, fit: BoxFit.cover, width: rightW, height: topRightH),
                    ),
                  ),

                  SizedBox(height: 10),

                  // small bottom thumbnail
                  Container(
                    width: rightW,
                    height: topRightH * 0.78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 6))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(thumb2, fit: BoxFit.cover, width: rightW, height: topRightH * 0.78),
                    ),
                  ),
                ],
              ),
            ),

            // Optional: gallery indicator or shadows if needed
          ],
        ),
      ),
    );
  }

}

final List<Map<String, String>> estatesData = [
  {
    "name": "Urban Heights Apartment",
    "rating": "4.8",
    "loc": "Sector 15, Hisar",
    "price": "230",
    "tag": "Apartment",
    "image": "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    "beds": "3 BHK",
    "area": "180 sq.m"
  },
  {
    "name": "The Aurelia Villa - Hisar",
    "rating": "4.9",
    "loc": "Rajguru Nagar, Hisar",
    "price": "520",
    "tag": "Villa",
    "image": "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
    "beds": "5 BHK",
    "area": "400 sq.m"
  },
  {
    "name": "Mill Sper House (Hisar)",
    "rating": "4.7",
    "loc": "Model Town, Hisar",
    "price": "271",
    "tag": "House",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
    "beds": "4 BHK",
    "area": "250 sq.m"
  },
  {
    "name": "Wings Tower Hisar",
    "rating": "4.6",
    "loc": "Camp Chowk, Hisar",
    "price": "220",
    "tag": "Apartment",
    "image": "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
    "beds": "2 BHK",
    "area": "120 sq.m"
  },
  {
    "name": "Green Valley Residence",
    "rating": "4.7",
    "loc": "Hisar Cantt",
    "price": "350",
    "tag": "Villa",
    "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
    "beds": "3 BHK",
    "area": "210 sq.m"
  },
];
