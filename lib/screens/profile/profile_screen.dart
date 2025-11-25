import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/permission/permisson_screen.dart';
import 'package:realestate/screens/profile/documents_screen.dart';
import 'package:realestate/screens/profile/property_transaction_detail_screen.dart';

import '../../constant/app_colors.dart';
import 'edit_profile_screen.dart';

// IMPORTANT: Initialize ScreenUtil in your main.dart like:
// ScreenUtilInit(
//   designSize: Size(375, 812),
//   builder: (_, __) => const MyApp(),,
// );

class ProfileController extends GetxController {
  var selectedTab = 0.obs; // 0=Transaction, 1=my_property, 2=payments

  // Purchased / owned properties
  final List<Transaction> transactions = [
    Transaction(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "230",
      "Raipur Road, Hisar",
      "4.8",
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Transaction(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "520",
      "Raipur Road, Hisar",
      "4.9",
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Transaction(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "310",
      "Raipur Road, Hisar",
      "4.7",
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
  ];

  // Upcoming payments (scheduled / due)
  final List<Payment> upcomingPayments = [
    Payment("Plot No. 21 Shree Shyam Kunj Phase 5", "Raipur Road, Hisar", "Dec 05, 2025", 230000, false),
    Payment("hree Shyam Kunj Phase 5 Plot", "Raipur Road, Hisar", "Dec 20, 2025", 520000, false),
  ];

  // Past payments
  final List<Payment> pastPayments = [
    Payment("Plot No. 21 Shree Shyam Kunj Phase 5", "Raipur Road, Hisar", "Nov 01, 2025", 89000, true),
    Payment("Security Deposit - Shree Shyam Kunj Plot", "Raipur Road, Hisar", "Oct 10, 2025", 3290, true),
  ];

  // Transactions (sale/rent actions) with location & date & image
  final List<Property> my_property = [
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5",
      "Raipur Road, Hisar",
      "Sale",
      "January 10, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5", "Raipur Road, Hisar",
      "Rent",
      "January 05, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
    Property(
      "Plot No. 21 Shree Shyam Kunj Phase 5", "Raipur Road, Hisar",
      "Booking",
      "September 15, 2025",
      true,
      "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    ),
  ];

}

class Transaction {
  final String name, price, location, rating, image;
  Transaction(this.name, this.price, this.location, this.rating, this.image);
}

class Property {
  final String title;
  final String location;
  final String tag; // Sale / Rent / Booking
  final String date;
  final bool completed;
  final String image; // new

  Property(this.title, this.location, this.tag, this.date, this.completed, this.image);
}

class Payment {
  final String title;
  final String location;
  final String date;
  final num amount;
  final bool paid;
  Payment(this.title, this.location, this.date, this.amount, this.paid);
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
        actions: [
          IconButton(
            icon: Icon(IconlyLight.document, color: Colors.black87),
            onPressed: () => Get.to(DocumentsScreen()),
          ),
          IconButton(
            icon: Icon(IconlyLight.setting, color: Colors.black87),
            onPressed: () =>Get.to(PermissionsScreen()),
          ),
        ],
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
                // SizedBox(height: 16.h),
                // _buildStatsRow(),
                SizedBox(height: 18.h),
                _buildTabs(ctrl),
                SizedBox(height: 18.h),
                Obx(() {
                  if (ctrl.selectedTab.value == 0) {
                    return _buildMyProperties(ctrl);
                  } else if (ctrl.selectedTab.value == 1) {
                    return _buildTransactions(
                      ctrl,
                      "${ctrl.my_property.length} transactions",
                    );
                  } else {
                    return _buildPaymentsSection(ctrl);
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
              radius: avatarSize / 2.5,
              child: Icon(IconlyLight.profile, size: 30),
              backgroundColor: Colors.grey.shade300,
              // backgroundImage: NetworkImage("https://i.pravatar.cc/300?u=mathew"),
            ),
            GestureDetector(
              onTap: () => Get.to(EditProfileScreen()),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(IconlyLight.edit, size: 14.w, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          "Chetan Sharma",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "8906327912",
          style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
        ),
      ],
    );
  }


  Widget _buildTabs(ProfileController c) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Obx(
              () => Row(
            children: [

              _tab("My Properties", 0, c),

              _tab("Transactions", 1, c),

              _tab("Payments", 2, c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, int index, ProfileController c) {
    final bool active = c.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedTab.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Transactions view ----------------
  Widget _buildMyProperties(ProfileController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "${c.my_property.length} Purchased Properties",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: c.my_property.length,
          itemBuilder: (ctx, i) {
            final t = c.my_property[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h, left: 4.w, right: 4.w),
            child: _PropertyTile(
              image: t.image,
              title: t.title,
              location: t.location,
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

  // ---------------- My Properties view ----------------
  Widget _buildTransactions(ProfileController c, String title) {
    final list = c.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, size: 20.w),
                onPressed: () {},
              ),
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: (0.70),
          ),
          itemCount: list.length,
          itemBuilder: (ctx, i) =>
              ListingCard(transaction: list[i]),
        ),
      ],
    );
  }

  // ---------------- Payments view (past + upcoming) ----------------
  Widget _buildPaymentsSection(ProfileController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 4.w),
        //   child: Text(
        //     "Payments",
        //     style: TextStyle(
        //       fontSize: 16.sp,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
        SizedBox(height: 12.h),
        // Upcoming Payments

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "Upcoming Payments",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: c.upcomingPayments.length,
          itemBuilder: (ctx, i) {
            final p = c.upcomingPayments[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: PaymentCard(
                title: p.title,
                location: p.location,
                date: p.date,
                amount: p.amount,
                paid: p.paid,
              ),
            );
          },
        ),


        SizedBox(height: 16.h),


        // Past Payments
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "Past Payments",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: c.pastPayments.length,
          itemBuilder: (ctx, i) {
            final p = c.pastPayments[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: PaymentCard(
                title: p.title,
                location: p.location,
                date: p.date,
                amount: p.amount,
                paid: p.paid,
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
  final Transaction transaction;

  const ListingCard({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    // card dimensions responsive
    final double cardWidth =
        (MediaQuery.of(context).size.width - 48.w) / 2; // padding + spacing accounted
    final double imageHeight = (cardWidth * 0.68).clamp(100.0, 160.0);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(transaction.image, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14.w),
                    SizedBox(width: 6.w),
                    Text(
                      transaction.rating,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        transaction.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== Transaction Tile ======================
class _PropertyTile extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String tag;
  final String date;
  final bool isCompleted;

  const _PropertyTile({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.tag,
    required this.date,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PropertyTransactionDetailScreen(
          image: image,
          title: "Plot No. 21 Shree Shyam Kunj Phase 5",
          location: "Raipur Road, Hisar",
          tag: "Purchase",
          date: "11/28/2021",
          details: {
            "checkIn": "11/28/2021",
            "checkOut": "01/28/2022",
            "owner": "Chetan Sharma",
            "paymentEmail": "user@mail.com",
          },
          paymentDetail: {
            "period": "2 months",
            "monthly": 220,
            "discount": 88,
            "total": 31250,
          },
          propertyType: PropertyType.township,
          // pass mapImage as the local path too if you want it to show as map preview:
          mapImage: image,
          view360Url: null,
        ));
      },

      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 78.w,
                height: 64.h,
                color: Colors.grey.shade200,
                child: image.isNotEmpty
                    ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.home_outlined, size: 30.w, color: Colors.grey[600]),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(strokeWidth: 2)));
                  },
                )
                    : Icon(Icons.home_outlined, size: 30.w, color: Colors.grey[600]),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12.w, color: Colors.grey),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.access_time,
                        size: 14.w,
                        color: isCompleted ? primary : Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "$tag • $date",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ====================== Payment Card ======================
class PaymentCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final num amount;
  final bool paid;

  const PaymentCard({
    Key? key,
    required this.title,
    required this.location,
    required this.date,
    required this.amount,
    this.paid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: paid ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              paid ? Icons.check : Icons.schedule,
              color: paid ? primary : Colors.orange,
              size: 28.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹$amount", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            ],
          ),
        ],
      ),
    );
  }
}
