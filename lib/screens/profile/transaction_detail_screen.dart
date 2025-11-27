// transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/profile/profile_screen.dart';

import '../../constant/app_colors.dart';

class TransactionListScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  const TransactionListScreen({required this.transactions, super.key});

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(IconlyLight.arrow_left_2),
        ),
        title: Text('All Transactions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // header row
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Property',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      'Amount',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      'Type',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                  return InkWell(
                    onTap: () =>
                        Get.to(() => TransactionDetailScreen(transaction: t)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 90.w, child: Text(_fmtDate(t.date))),
                          Expanded(
                            child: Text(
                              t.property,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              '₹${t.amount}',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 70.w,
                            child: Center(child: Text(t.type)),
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

// ------------------ Transaction Detail Screen ------------------
class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({required this.transaction, super.key});

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(IconlyLight.arrow_left_2)),

          title: Text('Transaction ${transaction.id}')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.property,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16.w),
                SizedBox(width: 6.w),
                Text(transaction.location),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('₹${transaction.amount}'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(_fmtDate(transaction.date)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Type', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(transaction.type),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(transaction.status),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reference',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(transaction.reference),
              ],
            ),
            SizedBox(height: 16.h),
            if (transaction.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  transaction.image,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
