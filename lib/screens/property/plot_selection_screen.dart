import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constant/app_colors.dart';
import '../../data/models/property_details_model.dart'; // Add this import

final Color _primary = primary;

class PlotModel {
  final String no;
  final String size;
  final String roadSide;
  final String facing;
  bool booked;
  final bool premium;

  PlotModel({
    required this.no,
    required this.size,
    required this.roadSide,
    required this.facing,
    this.booked = false,
    this.premium = false,
  });
}

class PlotSelectionWidget extends StatefulWidget {
  final List<PlotData> plotData; // Added
  final Function(String plotNo, String size) onPlotSelected;

  const PlotSelectionWidget({
    super.key, 
    required this.plotData, // Added
    required this.onPlotSelected,
  });

  @override
  State<PlotSelectionWidget> createState() => _PlotSelectionWidgetState();
}

class _PlotSelectionWidgetState extends State<PlotSelectionWidget> {
  String? selectedPlot;

  late final List<PlotModel> plots;

  @override
  void initState() {
    super.initState();
    if (widget.plotData.isNotEmpty) {
      plots = widget.plotData.map((e) {
        return PlotModel(
          no: e.number.split(' ').last, // Simple way to get 1001 from "Anandvan FarmHouses 1001"
          size: e.size,
          roadSide: "Main Road", // Default or you could parse from elsewhere
          facing: "North", // Default
          booked: e.status.toLowerCase() == 'booked' || e.status.toLowerCase() == 'sold',
          premium: e.number.contains('Premium'), 
        );
      }).toList();
    } else {
      // Fallback or leave empty as per "if/else" logic
      plots = [
        PlotModel(no: "101", size: "30×50", roadSide: "Main Road", facing: "East"),
        PlotModel(no: "102", size: "30×50", roadSide: "Inner Road", facing: "North", booked: true),
        PlotModel(no: "103", size: "30×50", roadSide: "Inner Road", facing: "East"),
        PlotModel(no: "104", size: "40×60", roadSide: "Main Road", facing: "South"),
        PlotModel(no: "105", size: "40×60", roadSide: "Inner Road", facing: "West"),
        PlotModel(no: "201", size: "30×50", roadSide: "Service Lane", facing: "North"),
        PlotModel(no: "202", size: "35×55", roadSide: "Inner Road", facing: "East"),
        PlotModel(no: "203", size: "30×50", roadSide: "Inner Road", facing: "West", booked: true),
        PlotModel(no: "204", size: "50×80", roadSide: "Main Road", facing: "South", premium: true),
        PlotModel(no: "301", size: "40×60", roadSide: "Inner Road", facing: "North"),
        PlotModel(no: "302", size: "40×60", roadSide: "Inner Road", facing: "East"),
        PlotModel(no: "PH-1", size: "60×90", roadSide: "Main Road", facing: "North-East", premium: true),
        PlotModel(no: "PH-2", size: "60×90", roadSide: "Main Road", facing: "North-West", premium: true),
      ];
    }
  }

  PlotModel? plotByNo(String no) {
    try {
      return plots.firstWhere((p) => p.no == no);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (plots.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend().animate().fadeIn(duration: 400.ms),
        SizedBox(height: 16.h),

        /// PLAN AREA AS WIDGET
        _buildInteractivePlan(),
      ],
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _legendItem(Icons.square_rounded, Colors.green.withOpacity(0.6), "Available"),
          SizedBox(width: 16.w),
          _legendItem(Icons.square_rounded, Colors.red.withOpacity(0.4), "Sold"),
          SizedBox(width: 16.w),
          _legendItem(Icons.square_rounded, primary, "Selected"),
          SizedBox(width: 16.w),
          _legendItem(Icons.stars_rounded, Colors.amber.withOpacity(0.8), "Premium"),
        ],
      ),
    );
  }

  Widget _legendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractivePlan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridSpacing = 12.w;
        final int columns = 5;
        final double availableW = constraints.maxWidth;
        final double cellWidth = (availableW - (columns - 1) * gridSpacing) / columns;

        return InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.7,
          maxScale: 2,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final p = plots[index];
              return _PlotBoxWidget(
                model: p,
                isSelected: selectedPlot == p.no,
                onTap: _handleTap,
              ).animate()
               .fadeIn(delay: (index * 50).ms)
               .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
            },
          ),
        );
      },
    );
  }

  void _handleTap(String plotNo) {
    final model = plotByNo(plotNo);
    if (model == null || model.booked) return;
    setState(() {
      selectedPlot = plotNo;
    });
    widget.onPlotSelected(model.no, model.size);
  }
}

class _PlotBoxWidget extends StatelessWidget {
  final PlotModel model;
  final bool isSelected;
  final Function(String) onTap;

  const _PlotBoxWidget({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool booked = model.booked;
    final bool premium = model.premium;

    Color borderColor;
    Color bgColor;
    Color textColor = Colors.white;

    if (booked) {
      borderColor = Colors.red.withOpacity(0.2);
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.white.withOpacity(0.3);
    } else if (isSelected) {
      borderColor = primary;
      bgColor = primary.withOpacity(0.2);
    } else if (premium) {
      borderColor = Colors.amber.withOpacity(0.5);
      bgColor = Colors.amber.withOpacity(0.1);
    } else {
      borderColor = Colors.white.withOpacity(0.1);
      bgColor = Colors.white.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: booked ? null : () => onTap(model.no),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              if (premium && !booked)
                Positioned(
                  top: 6.r,
                  right: 6.r,
                  child: Icon(Icons.stars_rounded, size: 12.sp, color: Colors.amber),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      model.no,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      model.size,
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
