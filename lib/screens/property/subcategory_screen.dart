import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:realestate/screens/property/property_deatils_screen.dart';
import '../../constant/app_colors.dart';

const String sitePlanImagePath =
    'https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg';
class SitePlanHeader extends StatelessWidget {
  final int availableCount;
  const SitePlanHeader({Key? key, required this.availableCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0,top: 16,right: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: SizedBox(
          height: 180.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background image (from local file). If file missing, show neutral background.
            Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius:
                BorderRadius.circular(24.r),
                child: Image.network(
                  sitePlanImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                    );
                  },
                ),
              ),


            ],
          ),

          // subtle dark gradient overlay to guarantee text contrast
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.black.withOpacity(0.28),
                    ],
                  ),
                ),
              ),

              // content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Plots in Hisar',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Text(
                      //   '$availableCount results • Starting ₹14 Lac',
                      //   style: TextStyle(
                      //     fontSize: 13.sp,
                      //     color: Colors.white.withOpacity(0.9),
                      //   ),
                      // ),
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
class PlotsOnlyScreen extends StatelessWidget {
  const PlotsOnlyScreen({Key? key}) : super(key: key);

  // All plots focused on Hisar
  static const List<Map<String, String>> plots = [
    {
      "title": "Shree Shyam Kunj Phase 2",
      "size": "30×50 ft",
      "price": "18.5",
      "location": "Raipur Road, Hisar, Haryana",
      "facing": "East Facing",
      "type": "Corner Plot",
      "rating": "4.9",
      "image": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
      "status": "available",
    },
    {
      "title": "Shree Shyam Kunj Phase 2",
      "size": "40×60 ft",
      "price": "32.0",
      "location": "Raipur Road, Hisar, Haryana",
      "facing": "North-East",
      "type": "Premium Corner",
      "rating": "4.8",
      "image": "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800",
      "status": "available",
    },
    {
      "title": "Shree Shyam Kunj Phase 2",
      "size": "35×60 ft",
      "price": "28.5",
      "location": "Raipur Road, Hisar, Haryana",
      "facing": "Park Facing",
      "type": "Regular",
      "rating": "4.6",
      "image": "https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=800",
      "status": "sold",
    },

  ];

  @override
  Widget build(BuildContext context) {
    final availableCount =
        plots.where((p) => p["status"] == "available").length;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(

            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(onPressed: (){
              Get.back();
            }, icon: Icon(CupertinoIcons.back)),
            title: Text(
              'Plots',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.black54),
                onPressed: () {
                  // optional: open filter sheet later
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // subtle header card with faint site-plan background
              SitePlanHeader(availableCount: 10,),

              // simple, non-intrusive filter chips (placeholder)
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 12.w),
              //   child: SizedBox(
              //     height: 42.h,
              //     child: ListView(
              //       scrollDirection: Axis.horizontal,
              //       children: [
              //         _MinimalChip(label: 'All', selected: true),
              //         SizedBox(width: 8.w),
              //         _MinimalChip(label: 'Corner'),
              //         SizedBox(width: 8.w),
              //         _MinimalChip(label: 'Park Facing'),
              //         SizedBox(width: 8.w),
              //         _MinimalChip(label: '30×50'),
              //         SizedBox(width: 8.w),
              //         _MinimalChip(label: '40×60'),
              //       ],
              //     ),
              //   ),
              // ),

              SizedBox(height: 12.h),

              // minimal list view of plot cards
              Expanded(
                child: ListView.separated(
                  padding:
                  EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                  itemCount: plots.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final p = plots[i];
                    return _PlotCard(
                      title: p['title']!,
                      size: p['size']!,
                      price: p['price']!,
                      location: p['location'] ?? '',
                      imageUrl: p['image']!,
                      type: p['type'] ?? '',
                      rating: p['rating'] ?? '0',
                      isSold: p['status'] == 'sold',
                      onTap: () {
                        if (p['status'] != 'sold') {
                          Get.to(() => PropertyDetailScreen());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: primary,
          //   child: Icon(Icons.map_outlined, color: Colors.white),
          //   onPressed: () {
          //     // Get.to(() => PlotSelectionScreen(onPlotSelected: (plotNo, size) {
          //     //   // handle selected plot
          //     // }));
          //   },
          // ),
        );
      },
    );
  }
}

class _MinimalChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _MinimalChip({Key? key, required this.label, this.selected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 13.sp)),
      selected: selected,
      onSelected: (_) {},
      selectedColor: primary,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    );
  }
}

class _PlotCard extends StatelessWidget {
  final String imageUrl, title, size, price, location, type, rating;
  final bool isSold;
  final VoidCallback onTap;

  const _PlotCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.size,
    required this.price,
    required this.location,
    required this.type,
    required this.rating,
    required this.isSold,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: isSold ? null : onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          height: 110.h,
          child: Row(
            children: [
              // image (rounded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10.r),
                  child: Image.network(
                    imageUrl,
                    width: 100.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110.w,
                      height: 100.h,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 28.sp),
                    ),
                  ),
                ),
              ),

              // info
              Expanded(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Row(
                        children: [
                          Expanded(
                            child: Text(title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(width: 6.w),

                        ],
                      ),
                      SizedBox(height: 6.h),
                      // size & location
                      Text('$size • $location',
                          style:
                          TextStyle(fontSize: 12.sp, color: Colors.black54)),
                      SizedBox(height: 6.h),
                      // price and rating / sold
                      Text('Starting From ₹$price Lac',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: primary)),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text('View Details',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11.sp)),
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


