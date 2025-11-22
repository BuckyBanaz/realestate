import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

import '../../constant/app_colors.dart';
import 'edit_profile_screen.dart';

// IMPORTANT: Initialize ScreenUtil in your main.dart like:
// ScreenUtilInit(
//   designSize: Size(375, 812),
//   builder: (_, __) => const MyApp(),
// );

class ProfileController extends GetxController {
  var selectedTab = 0.obs; // 0=Transaction, 1=Listings, 2=Sold

  final List<Property> listings = [
    Property("Fairview Apartment", "370", "Jakarta, Indonesia", "4.9", "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800"),
    Property("Shoolview House", "320", "Jakarta, Indonesia", "4.8", "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800"),
    Property("Greenwood Villa", "450", "Bali, Indonesia", "5.0", "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800"),
  ];

  final List<Property> sold = [
    Property("Bridgeland House", "520", "Semarang", "4.7", "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800"),
    Property("Palm Spring", "680", "Bandung", "4.9", "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800"),
  ];

  final List<Transaction> transactions = [
    Transaction("Wings Tower", "Rent", "November 21, 2021", true),
    Transaction("Bridgeland Modern House", "Rent", "December 17, 2021", true),
  ];
}

class Property {
  final String name, price, location, rating, image;
  Property(this.name, this.price, this.location, this.rating, this.image);
}

class Transaction {
  final String title, tag, date;
  final bool completed;
  Transaction(this.title, this.tag, this.date, this.completed);
}

// ====================== PROFILE SCREEN (RESPONSIVE) ======================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil is initialized in main
    final ctrl = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: Icon(IconlyLight.setting, color: Colors.black87), onPressed: () {})],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 16.h),
                _buildStatsRow(),
                SizedBox(height: 18.h),
                _buildTabs(ctrl),
                SizedBox(height: 18.h),
                Obx(() {
                  if (ctrl.selectedTab.value == 0) {
                    return _buildTransactions(ctrl);
                  } else if (ctrl.selectedTab.value == 1) {
                    return _buildListings(ctrl, "${ctrl.listings.length} listings");
                  } else {
                    return _buildListings(ctrl, "${ctrl.sold.length} sold", isSold: true);
                  }
                }),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double avatarSize = 120.w.clamp(72.0, 120.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300?u=mathew"),
            ),
            GestureDetector(
              onTap: () => Get.to(EditProfileScreen()),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 4))]),
                child: Icon(IconlyLight.edit, size: 20.w, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text("Mathew Adam", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h),
        Text("mathew@gmail.com", style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat("30", "Listings"),
        _stat("12", "Sold"),
        _stat("28", "Reviews"),
      ],
    );
  }

  Widget _stat(String num, String label) {
    return Column(
      children: [
        Text(num, style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildTabs(ProfileController c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(32.r)),
        child: Obx(() => Row(children: [
          _tab("Transactions", 0, c),
          _tab("Listings", 1, c),
          _tab("Sold", 2, c),
        ])),
      ),
    );
  }

  Widget _tab(String text, int index, ProfileController c) {
    final bool active = c.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w500, fontSize: 13.sp)),
        ),
      ),
    );
  }

  Widget _buildListings(ProfileController c, String title, {bool isSold = false}) {
    final list = isSold ? c.sold : c.listings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold))),
              IconButton(icon: Icon(Icons.more_horiz, size: 20.w), onPressed: () {}),
              SizedBox(width: 8.w),
              FloatingActionButton.small(
                backgroundColor: secondary,
                child: Icon(Icons.add, color: Colors.white, size: 18.w),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // GridView: shrinkWrap + NeverScrollableScrollPhysics because parent scrolls
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: (0.68),
          ),
          itemCount: list.length,
          itemBuilder: (ctx, i) => ListingCard(property: list[i], isSold: isSold),
        ),
      ],
    );
  }

  Widget _buildTransactions(ProfileController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text("${c.transactions.length} transactions", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ),
        SizedBox(height: 12.h),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: c.transactions.length,
          itemBuilder: (ctx, i) {
            final t = c.transactions[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TransactionCard(
                image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
                title: t.title,
                tag: t.tag,
                date: t.date,
                isCompleted: t.completed,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ====================== Listing Card (responsive, polished) ======================
class ListingCard extends StatelessWidget {
  final Property property;
  final bool isSold;

  const ListingCard({required this.property, this.isSold = false, super.key});

  @override
  Widget build(BuildContext context) {
    // card dimensions responsive
    final double cardWidth = (MediaQuery.of(context).size.width - 48.w) / 2; // padding + spacing accounted
    final double imageHeight = (cardWidth * 0.68).clamp(100.0, 160.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12.r, offset: Offset(0, 6.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(property.image, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("\$${property.price}/mo", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: secondary)),
              SizedBox(height: 6.h),
              Text(property.name, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              Row(children: [
                Icon(Icons.star, color: Colors.amber, size: 14.w),
                SizedBox(width: 6.w),
                Text(property.rating, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                SizedBox(width: 8.w),
                Expanded(child: Text(property.location, style: TextStyle(color: Colors.grey[600], fontSize: 11.sp), overflow: TextOverflow.ellipsis)),
              ])
            ]),
          ),
          // overlay icons
          Positioned.fill(child: Container()),
        ],
      ),
    );
  }
}

// ====================== Transaction Card (responsive) ======================
class TransactionCard extends StatelessWidget {
  final String image, title, tag, date;
  final bool isCompleted;

  const TransactionCard({super.key, required this.image, required this.title, required this.tag, required this.date, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8.r, offset: Offset(0, 4.h))],
      ),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.network(image, width: 88.w, height: 68.h, fit: BoxFit.cover)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(IconlyBold.heart, color: Colors.grey[400], size: 18.w), Spacer(), Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(16.r)), child: Text(tag, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12.sp)))]),
              SizedBox(height: 8.h),
              Text(title, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              Row(children: [Icon(isCompleted ? Icons.check_circle : Icons.access_time, size: 14.w, color: isCompleted ? primary : Colors.grey), SizedBox(width: 6.w), Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp))])
            ]),
          )
        ],
      ),
    );
  }
}
