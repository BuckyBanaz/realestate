import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';
import '../../data/controllers/transaction_controller.dart';
import '../widgets/shimmers.dart';
import 'package:realestate/Routes/appRoutes.dart';

class TransactionListScreen extends StatelessWidget {
  TransactionListScreen({Key? key}) : super(key: key);

  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Transactions',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: scaffoldColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: secondary,
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              // Header Row
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'TRANSACTION DETAILS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade600,
                          fontSize: 10.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      'AMOUNT',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                        fontSize: 10.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Transaction List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView.separated(
                      itemCount: 8,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, __) => const TransactionShimmer(),
                    );
                  }

                  if (controller.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconlyLight.document,
                              size: 64.sp, color: Colors.grey.withOpacity(0.3)),
                          SizedBox(height: 16.h),
                          Text(
                            "No transactions found",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.transactions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      final t = controller.transactions[i];
                      final isCompleted = t.status.toLowerCase() == 'completed';
                      final isReceived = t.amount.startsWith('+');

                      return GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.transactionDetail, arguments: t),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Status Icon
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  isReceived
                                      ? IconlyBold.arrow_down_2
                                      : isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.access_time_filled_rounded,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),

                              // Details
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.propertyName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(
                                          t.date,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 6.w),
                                          width: 3.w,
                                          height: 3.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text(
                                          "EMI #${t.emiNumber}",
                                          style: TextStyle(
                                            color: secondary.withOpacity(0.8),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Amount & Status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    t.amount,
                                    style: GoogleFonts.inter(
                                      color: isReceived
                                          ? Colors.green
                                          : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    t.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.1, end: 0),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Add a simple shimmer if it doesn't exist in shimmers.dart
class TransactionShimmer extends StatelessWidget {
  const TransactionShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150.w,
                  height: 12.h,
                  color: Colors.white.withOpacity(0.05),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 10.h,
                  color: Colors.white.withOpacity(0.05),
                ),
              ],
            ),
          ),
          Container(
            width: 60.w,
            height: 12.h,
            color: Colors.white.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
