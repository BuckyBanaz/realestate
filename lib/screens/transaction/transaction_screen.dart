import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data
     final List<Map<String, dynamic>> transactions = [
      {
        "id": "TXN001",
        "property": "Plot No. 21 Shree Shyam Kunj Phase 5",
        "location": "Raipur Road, Hisar",
        "date": "24-11-2025",
        "amount": "2,30,000",
        "type": "Received",
        "status": "Completed",
      },
      {
        "id": "TXN002",
        "property": "Plot No. 78 Galaxy Residency",
        "location": "Sector 12, Hisar",
        "date": "18-11-2025",
        "amount": "5,20,000",
        "type": "Received",
        "status": "Completed",
      },
      {
        "id": "TXN003",
        "property": "Block A - Park View Apartment",
        "location": "MG Road, Hisar",
        "date": "29-10-2025",
        "amount": "3,10,000",
        "type": "Paid",
        "status": "Pending",
      },
       {
        "id": "TXN004",
        "property": "Shop No. 12 Market Plaza",
        "location": "Old Bazar, Hisar",
        "date": "23-08-2025",
        "amount": "45,000",
        "type": "Paid",
        "status": "Completed",
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button if it's a main tab
        title: Text(
          'Transactions',
          style: GoogleFonts.inter(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 20.sp
          ),
        ),
        backgroundColor: scaffoldColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            // Header Row
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Property',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.sp),
                    ),
                  ),
                  Expanded(
                     flex: 1,
                    child: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.sp),
                    ),
                  ),
                  Expanded(
                     flex: 1,
                    child: Text(
                      'Amount',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // List
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (ctx, i) {
                  final t = transactions[i];
                  final isReceived = t['type'] == 'Received';

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: isReceived ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isReceived ? IconlyBold.arrow_down_2 : IconlyBold.arrow_up_2,
                            color: isReceived ? Colors.green : Colors.orange,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        
                        // Details
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['property'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                t['status'],
                                style: TextStyle(
                                  color: t['status'] == 'Completed' ? Colors.green : Colors.amber,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date & Amount
                         Expanded(
                           flex: 2,
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 t['date'],
                                 style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                               ),
                               Text(
                                 "${isReceived ? '+' : '-'} ₹${t['amount']}",
                                 style: TextStyle(
                                   color: isReceived ? Colors.green : Colors.white,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 13.sp,
                                 ),
                               ),
                             ],
                           ),
                         ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 80.h), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}
