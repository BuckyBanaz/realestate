// transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/data/models/profile_models.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/Routes/appRoutes.dart';
import 'package:realestate/screens/widgets/helpers.dart';

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
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Property',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      'Amount',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      'Type',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (ctx, i) {
                  final t = transactions[i];
                  final isReceived = t.amount.startsWith('+');
                  return InkWell(
                    onTap: () => Get.toNamed(AppRoutes.transactionDetail, arguments: t),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 90.w, child: Text(t.date)),
                          Expanded(
                            child: Text(
                              t.propertyName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              t.amount,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                color: isReceived ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70.w,
                            child: Center(
                              child: Text(
                                t.status,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: t.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
