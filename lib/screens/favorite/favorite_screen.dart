// lib/screens/favorite/favorite_screen_fixed.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/app_colors.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // initial data (you can load from backend instead)
  List<Map<String, dynamic>> savedProperties = [
    {
      "image": "assets/images/2.png",
      "title": "Wings Tower",
      "location": "Jakarta, Indonesia",
      "price": "220",
      "tag": "Apartment",
      "rating": "4.9"
    },
    {
      "image": "assets/images/1.png",
      "title": "Bridgeland Modern House",
      "location": "Semarang",
      "price": "380",
      "tag": "House",
      "rating": "4.8"
    },
    {
      "image": "assets/images/3.png",
      "title": "Skyline Villa",
      "location": "Bali",
      "price": "450",
      "tag": "Villa",
      "rating": "5.0"
    },
    {
      "image": "assets/images/4.png",
      "title": "Greenwood Residence",
      "location": "Bandung",
      "price": "295",
      "tag": "House",
      "rating": "4.7"
    },
  ];

  Map<String, dynamic>? _recentlyRemoved;
  int? _recentlyRemovedIndex;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final horizontalPadding = 16.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Saved Properties", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        automaticallyImplyLeading: true,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
        child: savedProperties.isEmpty ? _emptyState(context) : _listView(context, w),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 86, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No saved properties yet", style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Tap ♥ to save your favorite homes", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _listView(BuildContext context, double w) {
    return ListView.separated(
      itemCount: savedProperties.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) {
        final property = savedProperties[i];
        final key = ValueKey(property['title'] + i.toString());
        return Dismissible(
          key: key,
          direction: DismissDirection.endToStart,
          background: _dismissBackground(),
          confirmDismiss: (dir) async {
            // optional confirm before delete — return true to proceed
            return true;
          },
          onDismissed: (direction) => _handleRemove(i),
          child: SavedPropertyCard(
            image: property["image"],
            title: property["title"],
            location: property["location"],
            price: property["price"],
            tag: property["tag"],
            rating: property["rating"],
            onHeartTap: () {
              // toggle favorite locally — you can integrate backend
              _showSnack("${property['title']} removed from saved", undo: false);
              setState(() => savedProperties.removeAt(i));
            },
            onTap: () {
              // open property details
              // Get.to(PropertyDetailScreen(...));
            },
          ),
        );
      },
    );
  }

  Widget _dismissBackground() {
    // red background shown while swiping
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.delete, color: Colors.white),
        SizedBox(width: 8),
        Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  void _handleRemove(int index) {
    setState(() {
      _recentlyRemoved = Map.from(savedProperties[index]);
      _recentlyRemovedIndex = index;
      savedProperties.removeAt(index);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_recentlyRemoved!['title']} removed"),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.yellowAccent,
          onPressed: () {
            // restore
            if (_recentlyRemoved != null && _recentlyRemovedIndex != null) {
              setState(() {
                savedProperties.insert(_recentlyRemovedIndex!, _recentlyRemoved!);
                _recentlyRemoved = null;
                _recentlyRemovedIndex = null;
              });
            }
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSnack(String text, {bool undo = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

// Saved Property Card – improved & compact professional design
class SavedPropertyCard extends StatelessWidget {
  final String image, title, location, price, tag, rating;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTap;

  const SavedPropertyCard({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.tag,
    required this.rating,
    this.onTap,
    this.onHeartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardHeight = (w * 0.26).clamp(92.0, 140.0);
    final imageWidth = (cardHeight * 0.85).clamp(86.0, 120.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image.asset(image, width: imageWidth, height: double.infinity, fit: BoxFit.cover),
                    // Tag badge top-left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(18)),
                        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // title + heart
                      Row(
                        children: [
                          Expanded(
                            child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onHeartTap,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(IconlyLight.heart, color: Colors.redAccent, size: 20),
                            ),
                          ),
                        ],
                      ),

                      // location
                      Row(
                        children: [
                          Icon(IconlyLight.location, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(child: Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis)),
                        ],
                      ),

                      // rating + price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 6),
                              Text(rating, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ]),
                          ),
                          const Spacer(),
                          Text("\$$price/month", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: secondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
