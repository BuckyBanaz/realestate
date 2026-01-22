import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/constant/app_colors.dart';

class AreaConverterScreen extends StatefulWidget {
  const AreaConverterScreen({super.key});

  @override
  State<AreaConverterScreen> createState() => _AreaConverterScreenState();
}

class _AreaConverterScreenState extends State<AreaConverterScreen> {
  static const List<String> _units = [
    'Sq Ft',
    'Sq Yd',
    'Sq M',
    'Acre',
    'Grounds',
    'Aankadam',
    'Rood',
    'Chatak',
    'Perch',
    'Guntha',
    'Ares',
    'Biswa (Pucca)',
    'Biswa (Kaccha)',
  ];

  final TextEditingController _valueController = TextEditingController();
  String _fromUnit = 'Sq Ft';
  String _toUnit = 'Sq Yd';
  String _result = '-';

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _calculate() {
    final input = _valueController.text.trim();
    final value = double.tryParse(input);
    if (value == null) {
      setState(() => _result = '-');
      return;
    }
    final converted = _convertArea(value, _fromUnit, _toUnit);
    setState(() => _result = _formatNumber(converted));
  }

  double _convertArea(double value, String from, String to) {
    const toSqFt = {
      'Sq Ft': 1.0,
      'Sq Yd': 9.0,
      'Sq M': 10.7639,
      'Acre': 43560.0,
      'Grounds': 2400.0,
      'Aankadam': 72.0,
      'Rood': 10890.0,
      'Chatak': 45.0,
      'Perch': 272.25,
      'Guntha': 1089.0,
      'Ares': 1076.39,
      'Biswa (Pucca)': 1361.25,
      'Biswa (Kaccha)': 900.0,
    };
    final fromFactor = toSqFt[from] ?? 1.0;
    final toFactor = toSqFt[to] ?? 1.0;
    return (value * fromFactor) / toFactor;
  }

  String _unitLabel(String unit) {
    switch (unit) {
      case 'Sq Ft':
        return 'sq.ft.';
      case 'Sq Yd':
        return 'sq.yd.';
      case 'Sq M':
        return 'sq.m.';
      case 'Acre':
        return 'acre';
      case 'Grounds':
        return 'grounds';
      case 'Aankadam':
        return 'aankadam';
      case 'Rood':
        return 'rood';
      case 'Chatak':
        return 'chataks';
      case 'Perch':
        return 'perch';
      case 'Guntha':
        return 'guntha';
      case 'Ares':
        return 'ares';
      case 'Biswa (Pucca)':
        return 'biswa (pucca)';
      case 'Biswa (Kaccha)':
        return 'biswa (kaccha)';
      default:
        return unit.toLowerCase();
    }
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
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
          'Area Converter',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter area value',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'e.g. 150',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _calculate(),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromUnit,
                    dropdownColor: const Color(0xFF1E1E1E),
                    iconEnabledColor: Colors.white70,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              _unitLabel(unit),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _fromUnit = value);
                      _calculate();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toUnit,
                    dropdownColor: const Color(0xFF1E1E1E),
                    iconEnabledColor: Colors.white70,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(
                              _unitLabel(unit),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _toUnit = value);
                      _calculate();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: secondary, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Result: $_result ${_unitLabel(_toUnit)}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
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
