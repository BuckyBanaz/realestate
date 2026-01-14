import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/permission/permisson_screen.dart';
import 'package:realestate/screens/profile/documents_screen.dart';
import 'package:realestate/screens/profile/property_transaction_detail_screen.dart';
import 'package:realestate/screens/profile/transaction_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constant/app_colors.dart';
import 'edit_profile_screen.dart';

import 'package:realestate/data/controllers/profile_controller.dart';
import 'package:realestate/data/models/profile_models.dart';

// ====================== PROFILE SCREEN (RESPONSIVE) ======================

// ====================== PROFILE SCREEN (RESPONSIVE) ======================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil is initialized in main
    final ctrl = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
       title: Text(
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(IconlyLight.document, color: Theme.of(context).iconTheme.color),
            onPressed: () => Get.to(DocumentsScreen()),
          ),
          IconButton(
            icon: Icon(IconlyLight.setting, color: Theme.of(context).iconTheme.color),
            onPressed: () => Get.to(PermissionsScreen()),
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
                    return _buildTransactionsSummary(context, ctrl);
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
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Obx(
              () => Row(
                children: [
                  _tab(context, "My Properties", 0, c),
                  _tab(context, "Transactions", 1, c),
                  _tab(context, "Payments", 2, c),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _tab(BuildContext context, String text, int index, ProfileController c) {
    final bool active = c.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedTab.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active 
                ? Theme.of(context).cardColor 
                : Colors.transparent,
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
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
  // ---------------- Transaction Summary (excel-like rows) ----------------
  Widget _buildTransactionsSummary(BuildContext context, ProfileController c) {
    // show first 3 recent transactions and a "View All" button
    final recent = c.transactions.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.to(
                  () => RecentTransactionListScreen(transactions: c.transactions),
                ),
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // header row (excel-like)
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade800 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90.w,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Property',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90.w,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70.w,
                  child: Text(
                    'Type',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, i) {
              final t = recent[i];
              return GestureDetector(
                onTap: () =>
                    Get.to(() => TransactionDetailScreen(transaction: t)),
                child: TransactionRow(transaction: t),
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: 6.h),
            itemCount: recent.length,
          ),
        ],
      ),
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
// ------------------ Transaction Row (single line like excel) ------------------
class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionRow({required this.transaction, super.key});

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              _fmtDate(transaction.date),
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              transaction.property,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 90.w,
            child: Text(
              '₹${transaction.amount}',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
          SizedBox(
            width: 70.w,
            child: Center(
              child: Text(
                transaction.type,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: transaction.type == 'Received'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
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
        Get.to(
          () => PropertyTransactionDetailScreen(
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
          ),
        );
      },

      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 100.w,
                height: 80.h,
                color: Colors.grey.shade200,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.home_outlined,
                          size: 30.w,
                          color: Colors.grey[600],
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.home_outlined,
                        size: 30.w,
                        color: Colors.grey[600],
                      ),
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: paid 
                  ? Colors.green.withOpacity(0.15) 
                  : Colors.orange.withOpacity(0.15),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  location,
                  style: TextStyle(color:  Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹$amount",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                date,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
