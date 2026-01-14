// lib/screens/favorite/favorite_screen_fixed.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/screens/home/home_screen.dart';
import 'package:realestate/screens/home/modules/featured_properties_list.dart';

import '../../constant/app_colors.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // initial demo data (can come from backend)
  List<Map<String, dynamic>> savedProperties = [
    {
      "image": "assets/images/2.png",
      "title": "Plot No. 21 Shree Shyam Kunj Phase 5",
      "location": "Raipur Road, Hisar",
      "tag": "TOWNSHIPS",
      "priceText": "₹ 23L",
      "rating": "4.8",
    },
    {
      "image": "assets/images/1.png",
      "title": "Plot No. 22 Shree Shyam Kunj Phase 5",
      "location": "Raipur Road, Hisar",
      "tag": "FARM HOUSES",
      "priceText": "₹ 52L",
      "rating": "4.9",
    },
    {
      "image": "assets/images/3.png",
      "title": "Plot No. 24 Shree Shyam Kunj Phase 5",
      "location": "Raipur Road, Hisar",
      "tag": "SOCIETIES",
      "priceText": "₹ 31L",
      "rating": "4.7",
    },
  ];

  // recently removed for undo
  Map<String, dynamic>? _recentlyRemoved;
  int? _recentlyRemovedIndex;

  // UI state
  bool isGrid = false;
  String searchQuery = "";
  String activeFilter = "All";

  // Use the uploaded image path for empty state illustration
  // Developer note: this is the path of the uploaded image in your session
  final String uploadedDemoImage =
      "/mnt/data/df17d5fb-9cc3-4523-a110-3cac59234048.png";

  // helper to detect if string is a local file path
  bool _isLocalPath(String path) {
    return path.startsWith('/mnt/') || path.startsWith('/data/');
  }

  // Unified image widget: supports asset, network, or local file
  Widget _buildThumb(
    String path, {
    double width = 120,
    double height = 84,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      );
    }
    if (_isLocalPath(path)) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, width: width, height: height, fit: fit);
      } else {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, color: Colors.grey[500]),
        );
      }
    }
    // check for asset (starts with assets/...) or network
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit);
    }
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, color: Colors.grey[500]),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredProperties {
    final q = searchQuery.trim().toLowerCase();
    return savedProperties.where((p) {
      final title = (p['title'] ?? '').toString().toLowerCase();
      final loc = (p['location'] ?? '').toString().toLowerCase();
      final tag = (p['tag'] ?? '').toString().toLowerCase();
      final matchesQuery =
          q.isEmpty || title.contains(q) || loc.contains(q) || tag.contains(q);
      final matchesFilter =
          activeFilter == "All" || (p['tag'] ?? '') == activeFilter;
      return matchesQuery && matchesFilter;
    }).toList();
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
            if (_recentlyRemoved != null && _recentlyRemovedIndex != null) {
              setState(() {
                savedProperties.insert(
                  _recentlyRemovedIndex!,
                  _recentlyRemoved!,
                );
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

  void _toggleFavorite(int index) {
    // for demo simply remove — in real app toggle backend favorite flag
    setState(() {
      _recentlyRemoved = Map.from(savedProperties[index]);
      _recentlyRemovedIndex = index;
      savedProperties.removeAt(index);
    });
    _showSnack("${_recentlyRemoved!['title']} removed from saved", undo: true);
  }

  void _showSnack(String text, {bool undo = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProperties;
    final w = MediaQuery.of(context).size.width;
    final horizontalPadding = 14.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
       
        title: Text(
          "Saved Properties",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(IconlyLight.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // focus into search field (we use bottom search bar)
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(IconlyLight.more_circle, color: Theme.of(context).iconTheme.color),
            onSelected: (v) {
              // demo actions
              if (v == 'Clear') {
                setState(() => savedProperties.clear());
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'Clear', child: Text('Clear all')),
            ],
          ),
        ],
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Column(
          children: [
            // Search + View toggle
            _SearchField(
              onChanged: (v) => setState(() => searchQuery = v),
              hint: "Search by title, location or tag",
            ),

            // SizedBox(height: 12),
            //
            // // Filter chips
            // SizedBox(
            //   height: 40,
            //   child: ListView(
            //     scrollDirection: Axis.horizontal,
            //     children: [
            //       _filterChip("All"),
            //       SizedBox(width: 8),
            //       _filterChip("TOWNSHIPS"),
            //       SizedBox(width: 8),
            //       _filterChip("FARM HOUSES"),
            //       SizedBox(width: 8),
            //       _filterChip("SOCIETIES"),
            //       SizedBox(width: 8),
            //       _filterChip("AGRI LAND"),
            //     ],
            //   ),
            // ),
            SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 8,
                ),
                itemCount: nearbyEstates.length,
                itemBuilder: (ctx, i) {
                  final e = nearbyEstates[i];
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

            // Content
            // Expanded(
            //   child: filtered.isEmpty
            //       ? _emptyState(context)
            //       : (isGrid
            //             ? _gridView(context, filtered)
            //             : _listView(context, filtered)),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = activeFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : Colors.black87,
        ),
      ),
      selected: active,
      onSelected: (sel) => setState(() => activeFilter = sel ? label : "All"),
      selectedColor: secondary,
      backgroundColor: cardColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use uploaded image for illustration (falls back gracefully)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isLocalPath(uploadedDemoImage)
                ? (File(uploadedDemoImage).existsSync()
                      ? Image.file(
                          File(uploadedDemoImage),
                          width: 220,
                          height: 140,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 220,
                          height: 140,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.image, size: 48),
                        ))
                : Image.network(
                    uploadedDemoImage,
                    width: 220,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 18),
          Text(
            "No saved properties yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap ♥ on listings to save your favorites.",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // navigate to browse / featured
              Get.back();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 10,
              ),
              child: Text(
                "Browse Listings",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listView(BuildContext context, List<Map<String, dynamic>> items) {
    return ListView.separated(
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) {
        final property = items[i];
        final key = ValueKey(property['title'] + i.toString());
        return Dismissible(
          key: key,
          direction: DismissDirection.endToStart,
          background: _dismissBackground(),
          onDismissed: (direction) => _handleRemove(
            savedProperties.indexWhere((p) => p['title'] == property['title']),
          ),
          child: GestureDetector(
            onTap: () {
              // open details screen
              // Get.to(() => PropertyDetailScreen(...));
            },
            child: _SavedPropertyCard(
              image: property["image"] ?? "",
              title: property["title"] ?? "",
              location: property["location"] ?? "",
              price: property["priceText"] ?? "",
              tag: property["tag"] ?? "",
              rating: property["rating"] ?? "",
              onHeartTap: () {
                // For demo, remove from saved on heart tap (toggle)
                final originalIndex = savedProperties.indexWhere(
                  (p) => p['title'] == property['title'],
                );
                if (originalIndex != -1) _toggleFavorite(originalIndex);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _gridView(BuildContext context, List<Map<String, dynamic>> items) {
    final cross = 2;
    final spacing = 12.0;
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (ctx, idx) {
        final p = items[idx];
        return GestureDetector(
          onTap: () {
            // open details
          },
          child: _SavedPropertyGridCard(
            image: p['image'] ?? "",
            title: p['title'] ?? "",
            location: p['location'] ?? "",
            price: p['priceText'] ?? "",
            tag: p['tag'] ?? "",
            onHeartTap: () {
              final originalIndex = savedProperties.indexWhere(
                (pp) => pp['title'] == p['title'],
              );
              if (originalIndex != -1) _toggleFavorite(originalIndex);
            },
          ),
        );
      },
    );
  }

  Widget _dismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconlyLight.delete, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ----------------- Search Field -----------------
class _SearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hint;
  const _SearchField({Key? key, required this.onChanged, this.hint = "Search"})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.transparent
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconlyLight.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- List Card Widget -----------------
class _SavedPropertyCard extends StatelessWidget {
  final String image, title, location, price, tag, rating;
  final VoidCallback? onHeartTap;

  const _SavedPropertyCard({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.tag,
    required this.rating,
    this.onHeartTap,
  }) : super(key: key);

  bool _isLocal(String p) => p.startsWith('/mnt/') || p.startsWith('/data/');

  @override
  Widget build(BuildContext context) {
    final cardHeight = 116.0;
    final imageWidth = 140.0;

    Widget _img() {
      if (image.isEmpty)
        return Container(
          width: imageWidth,
          height: cardHeight,
          color: Colors.grey.shade200,
        );
      if (_isLocal(image)) {
        final f = File(image);
        if (f.existsSync())
          return Image.file(
            f,
            width: imageWidth,
            height: cardHeight,
            fit: BoxFit.cover,
          );
        return Container(
          width: imageWidth,
          height: cardHeight,
          color: Colors.grey.shade200,
        );
      }
      if (image.startsWith('assets/'))
        return Image.asset(
          image,
          width: imageWidth,
          height: cardHeight,
          fit: BoxFit.cover,
        );
      return Image.network(
        image,
        width: imageWidth,
        height: cardHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: imageWidth,
          height: cardHeight,
          color: Colors.grey.shade200,
        ),
      );
    }

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.grey.shade100
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 8, 
            offset: Offset(0, 6)
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _img(),
                // tag badge
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onHeartTap,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Icon(
                            IconlyLight.heart,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        IconlyLight.location,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      // Row(
                      //   children: [
                      //     Icon(Icons.star, color: Colors.amber, size: 14),
                      //     SizedBox(width: 6),
                      //     Text(
                      //       rating,
                      //       style: TextStyle(fontWeight: FontWeight.w600),
                      //     ),
                      //   ],
                      // ),
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

// ----------------- Grid Card Widget -----------------
class _SavedPropertyGridCard extends StatelessWidget {
  final String image, title, location, price, tag;
  final VoidCallback? onHeartTap;

  const _SavedPropertyGridCard({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.tag,
    this.onHeartTap,
  }) : super(key: key);

  bool _isLocal(String p) => p.startsWith('/mnt/') || p.startsWith('/data/');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              child: _imageWidget(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onHeartTap,
                      child: Icon(IconlyLight.heart, color: Colors.redAccent),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(price, style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageWidget() {
    if (image.isEmpty) return Container(color: Colors.grey.shade200);
    if (_isLocal(image)) {
      final f = File(image);
      if (f.existsSync())
        return Image.file(f, fit: BoxFit.cover, width: double.infinity);
      return Container(color: Colors.grey.shade200);
    }
    if (image.startsWith('assets/'))
      return Image.asset(image, fit: BoxFit.cover, width: double.infinity);
    return Image.network(
      image,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
    );
  }
}
