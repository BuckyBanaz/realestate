// transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/data/models/profile_models.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../constant/app_colors.dart';

class RecentTransactionListScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  const RecentTransactionListScreen({required this.transactions, super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrow_left_2, color: Theme.of(context).iconTheme.color),
        ),
        title: Text('All Transactions', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // header row
            Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 85.w,
                    child: Text(
                      'DATE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        fontSize: 10.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'PROPERTY',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        fontSize: 10.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      'AMOUNT',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        fontSize: 10.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      'STATUS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                        fontSize: 10.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                padding: EdgeInsets.only(bottom: 20.h),
                itemBuilder: (ctx, i) {
                  final t = transactions[i];
                  final isReceived = t.amount.startsWith('+');
                  final status = t.status.toLowerCase();
                  
                  Color statusColor;
                  Color statusBg;
                  
                  if (status == 'completed' || status == 'paid' || status == 'success') {
                    statusColor = const Color(0xFF00C853);
                    statusBg = statusColor.withOpacity(0.12);
                  } else if (status == 'pending' || status == 'processing') {
                    statusColor = const Color(0xFFFFAB00);
                    statusBg = statusColor.withOpacity(0.12);
                  } else {
                    statusColor = Colors.grey;
                    statusBg = statusColor.withOpacity(0.12);
                  }

                  return InkWell(
                    onTap: () => Get.toNamed(AppRoutes.transactionDetail, arguments: t),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 85.w, 
                            child: Text(
                              t.date,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ),
                          Expanded(
                            child: Text(
                              t.propertyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              t.amount,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 14.sp,
                                color: isReceived ? Colors.green : Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80.w,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: statusColor.withOpacity(0.2), width: 0.5),
                                ),
                                child: Text(
                                  t.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w900,
                                    color: statusColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.05, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
