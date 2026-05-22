import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constant/app_colors.dart';
import '../../data/models/property_list_model.dart';

final Color _primary = primary;

class PlotModel {
  final String no;
  final String size;
  final String roadSide;
  final String facing;
  bool booked;

  PlotModel({
    required this.no,
    required this.size,
    required this.roadSide,
    required this.facing,
    this.booked = false,
  });
}

class PlotSelectionWidget extends StatefulWidget {
  final List<PropertyListItem> plotData;
  final int? selectedPropertyId;
  final Function(PropertyListItem plot) onPlotSelected;

  const PlotSelectionWidget({
    super.key, 
    required this.plotData,
    this.selectedPropertyId,
    required this.onPlotSelected,
  });

  @override
  State<PlotSelectionWidget> createState() => _PlotSelectionWidgetState();
}

class _PlotSelectionWidgetState extends State<PlotSelectionWidget> {
  late List<PlotModel> plots;
  late Map<String, PropertyListItem> plotToProperty;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void didUpdateWidget(PlotSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plotData != widget.plotData || oldWidget.selectedPropertyId != widget.selectedPropertyId) {
      _prepareData();
    }
  }

  void _prepareData() {
    plotToProperty = {};
    if (widget.plotData.isNotEmpty) {
      plots = widget.plotData.map((e) {
        String plotNo = "";
        // Try to get Plot Number from attributes if available
        final attr = e.attributes.firstWhereOrNull((a) => 
          a.attribute.toLowerCase().contains("plot number") || 
          a.attribute.toLowerCase() == "number" ||
          a.attribute.toLowerCase() == "plot no"
        );
        
        if (attr != null && attr.value != null && attr.value!.trim().isNotEmpty) {
           plotNo = attr.value!.trim();
        } else {
           // Heuristic: If title is "Plot A66 Raja Ram Aero City", take "A66"
           final parts = e.title.split(' ');
           if (parts.length >= 2 && parts[0].toLowerCase() == 'plot') {
             plotNo = parts[1];
           } else {
             plotNo = e.title; // Fallback to full title if it's short
           }
        }
        
        // Final sanity check: if plotNo is too long or empty, truncate or fallback
        if (plotNo.length > 10) {
           plotNo = plotNo.split(' ').first;
        }
        
        plotToProperty[plotNo] = e;
        
        return PlotModel(
          no: plotNo,
          size: e.area,
          roadSide: "Main Road",
          facing: "North",
          booked: e.status.toLowerCase() == 'sold' || e.status.toLowerCase() == 'hold',
        );
      }).toList();
    } else {
      plots = [];
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
              final property = plotToProperty[p.no];
              final bool isSelected = property?.id == widget.selectedPropertyId;

              return _PlotBoxWidget(
                model: p,
                isSelected: isSelected,
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
    final property = plotToProperty[plotNo];
    if (property == null) return;
    
    final status = property.status.toLowerCase();
    if (status == 'sold' || status == 'hold') {
      Get.defaultDialog(
        title: "Plot Unavailable",
        backgroundColor: const Color(0xFF1E1E1E),
        titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        middleTextStyle: GoogleFonts.inter(color: Colors.white70),
        middleText: "This plot is already ${status == 'sold' ? 'Sold' : 'on Hold'}. Please select another available plot.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: primary,
        onConfirm: () => Get.back(),
      );
      return;
    }
    
    widget.onPlotSelected(property);
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
    } else {
      borderColor = Colors.green.withOpacity(0.3);
      bgColor = Colors.green.withOpacity(0.1);
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
