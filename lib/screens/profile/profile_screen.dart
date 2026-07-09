import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/permission/permisson_screen.dart';
import 'package:realestate/screens/profile/documents_screen.dart';
import 'package:realestate/screens/profile/property_transaction_detail_screen.dart';
import 'package:realestate/screens/profile/transaction_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/shimmers.dart';
import '../../constant/app_colors.dart';
import 'edit_profile_screen.dart';

import 'package:realestate/data/controllers/profile_controller.dart';
import 'package:realestate/data/models/account_data_model.dart';
import 'package:realestate/screens/widgets/helpers.dart';

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
            icon: Icon(
              IconlyLight.document,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Get.to(DocumentsScreen()),
          ),
          IconButton(
            icon: Icon(
              IconlyLight.setting,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Get.to(const PermissionsScreen()),
          ),
          IconButton(
            icon: const Icon(IconlyLight.logout, color: Colors.redAccent),
            onPressed: () => _showLogoutConfirmation(context, ctrl),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefreshTab(ctrl),
          color: secondary,
          backgroundColor: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
      ),
    );
  }

  Future<void> _onRefreshTab(ProfileController ctrl) async {
    switch (ctrl.selectedTab.value) {
      case 0:
        await ctrl.fetchAccountData();
        break;
      case 1:
        await ctrl.fetchProfileTransactions();
        break;
      case 2:
        await ctrl.fetchAccountData();
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    final double avatarSize = 120.w.clamp(72.0, 120.0);
    final ctrl = Get.find<ProfileController>();
    final double innerSize = (avatarSize / 2.5) * 2;

    return Obx(
      () => Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: ctrl.currentUser['profile_image'] != null &&
                        ctrl.currentUser['profile_image'].toString().isNotEmpty
                    ? ClipOval(
                        child: CustomImage(
                          imageUrl: ctrl.currentUser['profile_image'].toString(),
                          width: innerSize,
                          height: innerSize,
                          fit: BoxFit.cover,
                          fallbackAsset: 'assets/images/download.jpg',
                          errorWidget: (_, __, ___) => Icon(
                            IconlyBold.profile,
                            size: innerSize * 0.5,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        IconlyBold.profile,
                        size: innerSize * 0.5,
                        color: Colors.white,
                      ),
              ),
              GestureDetector(
                onTap: () => Get.to(const EditProfileScreen()),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    IconlyLight.edit,
                    size: 14.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            ctrl.currentUser['name'] ?? "User Name",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            ctrl.currentUser['phone'] ?? "Phone Number",
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
        ],
      ),
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
      },
    );
  }

  Widget _tab(
    BuildContext context,
    String text,
    int index,
    ProfileController c,
  ) {
    final bool active = c.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedTab.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).cardColor : Colors.transparent,
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
    return Obx(() {
      if (c.isAccountDataLoading.value) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, __) => ShimmerContainer(
            width: double.infinity,
            height: 100.h,
            radius: 12.r,
          ),
        );
      }

      if (c.my_property.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(40.h),
            child: Text(
              "No properties owned yet.",
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
        );
      }

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
              final prop = c.my_property[i];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h, left: 4.w, right: 4.w),
                child: _PropertyTile(propertyData: prop),
              );
            },
          ),
        ],
      );
    });
  }

  // ---------------- My Properties view ----------------
  // ---------------- Transaction Summary (excel-like rows) ----------------
  Widget _buildTransactionsSummary(BuildContext context, ProfileController c) {
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
                  () =>
                      RecentTransactionListScreen(transactions: c.transactions),
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

          SizedBox(height: 8.h),

          SizedBox(height: 8.h),

          Obx(() {
            if (c.isTransactionsLoading.value) {
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, i) => ShimmerContainer(
                  width: double.infinity,
                  height: 60.h,
                  radius: 8.r,
                ),
                separatorBuilder: (_, __) => SizedBox(height: 6.h),
                itemCount: 3,
              );
            }

            final recent = c.transactions.take(3).toList();

            if (recent.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    "No transactions found",
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                final t = recent[i];
                return GestureDetector(
                  onTap: () =>
                      Get.toNamed(AppRoutes.transactionDetail, arguments: t),
                  child: TransactionRow(transaction: t),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 6.h),
              itemCount: recent.length,
            );
          }),
        ],
      ),
    );
  }

  // ---------------- Payments view (past + upcoming) ----------------
  Widget _buildPaymentsSection(ProfileController c) {
    return Obx(() {
      if (c.isAccountDataLoading.value) {
        return Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ShimmerContainer(
                width: double.infinity,
                height: 80.h,
                radius: 12.r,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          if (c.upcomingPayments.isNotEmpty) ...[
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
                  child: PaymentCard(payment: p),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
          if (c.pastPayments.isNotEmpty) ...[
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
                  child: PaymentCard(payment: p),
                );
              },
            ),
          ],
          if (c.upcomingPayments.isEmpty && c.pastPayments.isEmpty)
            Center(
              child: Text(
                "No payments records found.",
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
            ),
        ],
      );
    });
  }

  void _showLogoutConfirmation(BuildContext context, ProfileController ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyLight.logout,
                  color: Colors.redAccent,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Logout Confirmation",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Are you sure you want to logout? You will need to login again to access your account.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.logout(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Logout",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }
}

// ====================== Listing Card (responsive, polished) ======================
// ------------------ Transaction Row (single line like excel) ------------------
class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionRow({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isReceived = transaction.amount.startsWith('+');
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
            child: Text(transaction.date, style: TextStyle(fontSize: 12.sp)),
          ),
          Expanded(
            child: Text(
              transaction.propertyName,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 90.w,
            child: Text(
              transaction.amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: isReceived ? Colors.green : Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 70.w,
            child: Center(
              child: Text(
                transaction.status,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: transaction.status.toLowerCase() == 'completed'
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
  final OwnedProperty propertyData;

  const _PropertyTile({Key? key, required this.propertyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = propertyData.property;
    final ctrl = Get.find<ProfileController>();
    final finance = propertyData.finance.isNotEmpty
        ? propertyData.finance.first
        : null;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => PropertyTransactionDetailScreen(
            image: p.image,
            title: p.title,
            location: p.address,
            tag: "Owned",
            date: p.saleDate,
            details: {
              "checkIn": p.saleDate,
              "checkOut": "-",
              "owner": ctrl.currentUser['name'] ?? "Owner",
              "paymentEmail": ctrl.currentUser['email'] ?? "Email",
            },
            paymentDetail: {
              "period": "-",
              "monthly": "-",
              "discount": "0",
              "total": finance?.totalAmount ?? "0",
              "paid": finance?.paidAmount ?? "0",
              "balance": finance?.balance ?? "0",
            },
            propertyType: PropertyType.township,
            mapImage: p.image,
            view360Url: null,
            propertyId: p.id,
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
                child: p.image.isNotEmpty
                    ? CustomImage(
                        imageUrl: p.image,
                        width: 100.w,
                        height: 80.h,
                        borderRadius: 8.r,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.home_outlined,
                          size: 30.w,
                          color: Colors.grey[600],
                        ),
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
                    p.title,
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
                          p.address,
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
                      Icon(Icons.check_circle, size: 14.w, color: primary),
                      SizedBox(width: 8.w),
                      Text(
                        "Owned • ${p.saleDate.split('T').first}",
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
  final PaymentItem payment;

  const PaymentCard({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status.toLowerCase() == 'paid';
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
              color: isPaid
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isPaid ? Icons.check : Icons.schedule,
              color: isPaid ? primary : Colors.orange,
              size: 28.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EMI #${payment.emiNumber} - ${payment.paymentType.toUpperCase()}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Status: ${payment.status}",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${payment.amount}",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                payment.paidDate,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
