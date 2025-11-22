import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/screens/search/search_screen.dart';

import '../home/home_screen.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:  Icon(IconlyLight.filter, color: secondary),
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
                  icon:  Icon(IconlyLight.filter_2,color: secondary,),
                  onPressed: () {},
                ),
                IconButton(
                  icon:  Icon(Icons.grid_view,color: secondary,),
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
                return ResultCard(
                  name: data["name"]!,
                  rating: data["rating"]!,
                  location: data["loc"]!,
                  price: data["price"]!,
                  tag: data["tag"]!,
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

// Tera data
final List<Map<String, String>> estatesData = [
  {"name": "Sky Dandelions Apartment", "rating": "4.9", "loc": "Jakarta, Indonesia", "price": "290", "tag": "Apartment"},
  {"name": "The Aurelia Villa", "rating": "4.9", "loc": "Bali", "price": "520", "tag": "Villa"},
  {"name": "Mill Sper House", "rating": "4.8", "loc": "Bandung", "price": "271", "tag": "House"},
  {"name": "Wings Tower", "rating": "4.9", "loc": "Jakarta", "price": "220", "tag": "Apartment"},
  {"name": "Green Paradise Residence", "rating": "4.7", "loc": "Yogyakarta", "price": "350", "tag": "Villa"},
];