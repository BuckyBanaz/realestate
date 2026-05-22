import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:realestate/screens/widgets/pdf_helper.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) {
      return const Scaffold(body: Center(child: Text("No transaction data")));
    }
    final TransactionModel transaction = Get.arguments as TransactionModel;
    final String statusStr = transaction.status.toLowerCase();
    final bool isSuccess = statusStr == 'completed' || statusStr == 'paid' || statusStr == 'success';
    final bool isReceived = transaction.amount.startsWith('+');

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22.sp),
        ),
        title: Text(
          'Transaction Receipt',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: scaffoldColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Status Icon & Amount Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSuccess
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
                      color: isSuccess ? Colors.green : Colors.orange,
                      size: 48.sp,
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 500), curve: Curves.elasticOut),
                  SizedBox(height: 16.h),
                  Text(
                    transaction.status.toUpperCase(),
                    style: TextStyle(
                      color: isSuccess ? Colors.green : Colors.orange,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                  SizedBox(height: 8.h),
                  Text(
                    "${isReceived ? '+' : '-'} ₹${formatFullPrice(transaction.amountValue)}",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 400)).fadeIn(),
                ],
              ),
            ),
            SizedBox(height: 40.h),

            // Details Card
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Property Name", transaction.propertyName, isBold: true),
                  _buildDivider(),
                  _buildDetailRow("Date", transaction.date),
                  _buildDivider(),
                  _buildDetailRow("EMI Number", "EMI #${transaction.emiNumber}"),
                  _buildDivider(),
                  _buildDetailRow("Payment Type", transaction.paymentType.toUpperCase()),
                  _buildDivider(),
                  _buildDetailRow("Reference ID", "TXN-${transaction.propertyName.hashCode.abs().toString().substring(0, 6)}"),
                ],
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 500)).slideY(begin: 0.1, end: 0),

            SizedBox(height: 30.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Download Receipt",
                    IconlyLight.download,
                    onTap: () => ReceiptPdfHelper.generateAndDownloadReceipt(transaction),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildActionButton(
                    "Share Details",
                    IconlyLight.send,
                    onTap: () => _shareDetails(transaction),
                    isOutline: true,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: const Duration(milliseconds: 700)),

            SizedBox(height: 40.h),
            
            // Helpful Tip
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(IconlyLight.info_square, color: primary, size: 18.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "For any queries regarding this transaction, please contact our support team with the reference ID.",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
          ],
        ),
      ),
    );
  }

  void _shareDetails(TransactionModel transaction) {
    final status = transaction.status.toUpperCase();
    final amount = "${transaction.amount.startsWith('+') ? '+' : '-'} ₹${formatFullPrice(transaction.amountValue)}";
    final message = [
      "Transaction Receipt",
      "Status: $status",
      "Amount: $amount",
      "Property: ${transaction.propertyName}",
      "Date: ${transaction.date}",
      "EMI: EMI #${transaction.emiNumber}",
      "Payment Type: ${transaction.paymentType.toUpperCase()}",
    ].join("\n");

    Share.share(message, subject: "Transaction Receipt");
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildActionButton(String label, IconData icon, {required VoidCallback onTap, bool isOutline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : primary,
          borderRadius: BorderRadius.circular(18.r),
          border: isOutline ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
