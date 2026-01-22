import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:realestate/constant/app_colors.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _emiDateController = TextEditingController();

  String _emi = '0';

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    _monthsController.dispose();
    _emiDateController.dispose();
    super.dispose();
  }

  void _calculateEmi() {
    final principal = double.tryParse(_amountController.text.trim()) ?? 0;
    final annualRate = double.tryParse(_interestController.text.trim()) ?? 0;
    final months = int.tryParse(_monthsController.text.trim()) ?? 0;

    if (principal <= 0 || annualRate <= 0 || months <= 0) {
      setState(() => _emi = '0');
      return;
    }

    final monthlyRate = annualRate / 12 / 100;
    final factor = pow(1 + monthlyRate, months);
    final emi = principal * monthlyRate * factor / (factor - 1);
    setState(() => _emi = emi.toStringAsFixed(2));
  }

  Future<void> _pickEmiDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    _emiDateController.text = DateFormat('dd MMM yyyy').format(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldColor,
         leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          'EMI Calculator',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EMI Calculator',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    label: 'Amount (₹)',
                    controller: _amountController,
                    hint: 'Enter amount',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _inputField(
                    label: 'Interest (%)',
                    controller: _interestController,
                    hint: 'Interest %',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    label: 'Months',
                    controller: _monthsController,
                    hint: 'No. of Months',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _inputField(
                    label: 'EMI Date',
                    controller: _emiDateController,
                    hint: 'Select date',
                    readOnly: true,
                    onTap: _pickEmiDate,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: 180.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _calculateEmi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Calculate EMI',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Text(
                  'EMI Per Month: ',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹$_emi',
                  style: GoogleFonts.inter(
                    color: Colors.greenAccent,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white, fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
