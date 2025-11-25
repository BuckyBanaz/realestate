// // plot_selection_screen_fixed.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../constant/app_colors.dart';
//
// final Color _primary = primary; // your app color
//
// class PlotModel {
//   final String no;
//   final String size;
//   final String roadSide; // e.g. "Main Road", "Inner Road"
//   final String facing; // e.g. "North", "East"
//   bool booked;
//   final bool premium;
//
//   PlotModel({
//     required this.no,
//     required this.size,
//     required this.roadSide,
//     required this.facing,
//     this.booked = false,
//     this.premium = false,
//   });
// }
//
// class PlotSelectionScreen extends StatefulWidget {
//   final Function(String plotNo, String size) onPlotSelected;
//
//   const PlotSelectionScreen({Key? key, required this.onPlotSelected})
//     : super(key: key);
//
//   @override
//   State<PlotSelectionScreen> createState() => _PlotSelectionScreenState();
// }
//
// class _PlotSelectionScreenState extends State<PlotSelectionScreen> {
//   String? selectedPlot;
//
//   late final List<PlotModel> plots;
//   // inside _PlotSelectionScreenState
//   OverlayEntry? _tooltipEntry;
//
//   void _showQuickInfo(BuildContext itemContext, PlotModel model) {
//     _tooltipEntry?.remove();
//     _tooltipEntry = null;
//
//     final renderBox = itemContext.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;
//
//     final overlay = Overlay.of(context);
//     if (overlay == null) return;
//
//     final itemOffset = renderBox.localToGlobal(Offset.zero);
//     final itemSize = renderBox.size;
//     final screenW = MediaQuery.of(context).size.width;
//
//     const tooltipMaxWidth = 220.0;
//     double left = itemOffset.dx + (itemSize.width / 2) - (tooltipMaxWidth / 2);
//     left = left.clamp(8.0, screenW - tooltipMaxWidth - 8.0);
//
//     double top;
//     if (itemOffset.dy < 80) {
//       top = itemOffset.dy + itemSize.height + 8.0;
//     } else {
//       top = itemOffset.dy - 8.0 - 56.0;
//     }
//
//     _tooltipEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         left: left,
//         top: top,
//         width: tooltipMaxWidth,
//         child: Material(
//           color: Colors.transparent,
//           child: _buildTooltipCard(model),
//         ),
//       ),
//     );
//
//     overlay.insert(_tooltipEntry!);
//
//     Future.delayed(const Duration(milliseconds: 2500)).then((_) {
//       try {
//         _tooltipEntry?.remove();
//       } catch (_) {}
//       _tooltipEntry = null;
//     });
//   }
//
//   Widget _buildTooltipCard(PlotModel model) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 6),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.black87,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Plot ${model.no}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.remove_road_sharp, size: 14, color: Colors.white70),
//                 const SizedBox(width: 6),
//                 Text(
//                   model.roadSide,
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.explore, size: 14, color: Colors.white70),
//                 const SizedBox(width: 6),
//                 Text(
//                   model.facing,
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     plots = [
//       PlotModel(
//         no: "101",
//         size: "30×50",
//         roadSide: "Main Road",
//         facing: "East",
//       ),
//       PlotModel(
//         no: "102",
//         size: "30×50",
//         roadSide: "Inner Road",
//         facing: "North",
//         booked: true,
//       ),
//       PlotModel(
//         no: "103",
//         size: "30×50",
//         roadSide: "Inner Road",
//         facing: "East",
//       ),
//       PlotModel(
//         no: "104",
//         size: "40×60",
//         roadSide: "Main Road",
//         facing: "South",
//       ),
//       PlotModel(
//         no: "105",
//         size: "40×60",
//         roadSide: "Inner Road",
//         facing: "West",
//       ),
//       PlotModel(
//         no: "201",
//         size: "30×50",
//         roadSide: "Service Lane",
//         facing: "North",
//       ),
//       PlotModel(
//         no: "202",
//         size: "35×55",
//         roadSide: "Inner Road",
//         facing: "East",
//       ),
//       PlotModel(
//         no: "203",
//         size: "30×50",
//         roadSide: "Inner Road",
//         facing: "West",
//         booked: true,
//       ),
//       PlotModel(
//         no: "204",
//         size: "50×80",
//         roadSide: "Main Road",
//         facing: "South",
//         premium: true,
//       ),
//       PlotModel(
//         no: "301",
//         size: "40×60",
//         roadSide: "Inner Road",
//         facing: "North",
//       ),
//       PlotModel(
//         no: "302",
//         size: "40×60",
//         roadSide: "Inner Road",
//         facing: "East",
//       ),
//       PlotModel(
//         no: "PH-1",
//         size: "60×90",
//         roadSide: "Main Road",
//         facing: "North-East",
//         premium: true,
//       ),
//       PlotModel(
//         no: "PH-2",
//         size: "60×90",
//         roadSide: "Main Road",
//         facing: "North-West",
//         premium: true,
//       ),
//     ];
//   }
//
//   PlotModel plotByNo(String no) => plots.firstWhere((p) => p.no == no);
//
//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final screenW = media.size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black87),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Select Your Plot",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline, color: _primary),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Legend & North
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     _legendItem(
//                       Icons.crop_square,
//                       Colors.green.shade500,
//                       "Available",
//                     ),
//                     const SizedBox(width: 12),
//                     _legendItem(Icons.crop_square, Colors.red.shade500, "Sold"),
//                     const SizedBox(width: 12),
//                     _legendItem(Icons.crop_square, _primary, "Selected"),
//                     const SizedBox(width: 12),
//                     _legendItem(Icons.star, Colors.amber.shade700, "Premium"),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 10),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.arrow_upward, color: _primary, size: 24),
//                       Text(
//                         "N",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Interactive plan area
//           Expanded(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final double availableW = constraints.maxWidth;
//                 final double horizontalPadding =
//                     24.0; // left+right padding space used below
//                 final double gridSpacing = 10.0;
//                 final int columns = 5;
//
//                 // compute base cell width for 6 columns
//                 final double totalSpacing =
//                     (columns - 1) * gridSpacing + horizontalPadding;
//                 double cellWidth = (availableW - totalSpacing) / columns;
//
//                 // clamp cell width to sensible values
//                 cellWidth = cellWidth.clamp(56.0, 180.0);
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       color: Colors.white,
//                       child: InteractiveViewer(
//                         panEnabled: true,
//                         scaleEnabled: true,
//                         minScale: 0.6,
//                         maxScale: 3.5,
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints(minWidth: availableW),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             child: GridView.count(
//                               crossAxisCount: columns,
//                               shrinkWrap: true,
//                               physics:
//                                   const NeverScrollableScrollPhysics(), // InteractiveViewer will handle pan/zoom
//                               crossAxisSpacing: gridSpacing,
//                               mainAxisSpacing: gridSpacing,
//                               childAspectRatio:
//                                   1.0, // roughly square, adjust if you want rectangles
//                               padding: EdgeInsets.zero,
//                               children: plots.map((p) {
//                                 // make premium boxes slightly smaller
//                                 final double finalWidth = p.premium
//                                     ? (cellWidth * 0.78)
//                                     : cellWidth;
//                                 return Align(
//                                   alignment: Alignment.center,
//                                   child: _PlotBoxWidget(
//                                     model: p,
//                                     width: finalWidth,
//                                     isSelected: selectedPlot == p.no,
//                                     onTap: _onPlotTap,
//                                     onLongPress: _showPlotDetails,
//                                     onShowInfo:
//                                         (BuildContext ctx, PlotModel m) =>
//                                             _showQuickInfo(ctx, m),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SafeArea(
//           child: SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton(
//               onPressed: selectedPlot == null
//                   ? null
//                   : () {
//                       final model = plotByNo(selectedPlot!);
//                       widget.onPlotSelected(selectedPlot!, model.size);
//                       Get.back();
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: selectedPlot == null
//                     ? Colors.grey.shade400
//                     : _primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 selectedPlot == null
//                     ? "Please Select a Plot"
//                     : "Continue → Plot $selectedPlot (${plotByNo(selectedPlot!).size})",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _onPlotTap(String plotNo) {
//     final model = plotByNo(plotNo);
//     if (model.booked) return;
//     setState(() {
//       if (selectedPlot == plotNo)
//         selectedPlot = null;
//       else
//         selectedPlot = plotNo;
//     });
//   }
//
//   void _showPlotDetails(String plotNo) {
//     final model = plotByNo(plotNo);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         final bool isBooked = model.booked;
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(ctx).viewInsets.bottom,
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Wrap(
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Plot ${model.no}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     if (isBooked)
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           'Sold',
//                           style: TextStyle(color: Colors.red.shade700),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Size: ${model.size}',
//                         style: const TextStyle(fontSize: 15),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Facing: ${model.facing}',
//                         style: const TextStyle(fontSize: 15),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Road Side: ${model.roadSide}',
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: isBooked
//                             ? null
//                             : () {
//                                 setState(() => selectedPlot = model.no);
//                                 Navigator.of(ctx).pop();
//                               },
//                         child: Text(
//                           selectedPlot == model.no ? 'Selected' : 'Select',
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                           if (!model.booked) {
//                             setState(() {
//                               model.booked = true;
//                               if (selectedPlot == model.no) selectedPlot = null;
//                             });
//                             Get.snackbar(
//                               'Reserved',
//                               'Plot ${model.no} reserved',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                           }
//                         },
//                         child: const Text('Book / Reserve'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _legendItem(IconData icon, Color color, String label) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: color),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//         ),
//       ],
//     );
//   }
// }
//
// class _PlotBoxWidget extends StatelessWidget {
//   final PlotModel model;
//   final double width;
//   final bool isSelected;
//   final void Function(String) onTap;
//   final void Function(String) onLongPress;
//   final void Function(BuildContext, PlotModel) onShowInfo;
//
//   const _PlotBoxWidget({
//     Key? key,
//     required this.model,
//     required this.width,
//     required this.isSelected,
//     required this.onTap,
//     required this.onLongPress,
//     required this.onShowInfo,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isBooked = model.booked;
//     final bool premium = model.premium;
//
//     // width is provided by parent (Grid cell size); premium already reduced upstream
//     final double w = width.clamp(
//       48.0,
//       MediaQuery.of(context).size.width * 0.28,
//     );
//     final double h = premium ? 112 : (w * 1.0).clamp(68.0, 140.0);
//
//     final borderColor = isBooked
//         ? Colors.red.shade300
//         : isSelected
//         ? _primary
//         : premium
//         ? Colors.amber.shade400
//         : Colors.green.shade300;
//     final bgColor = isBooked
//         ? Colors.red.shade50
//         : isSelected
//         ? _primary
//         : premium
//         ? Colors.amber.shade50
//         : Colors.green.shade50;
//
//     return GestureDetector(
//       onTap: isBooked
//           ? null
//           : () {
//               onTap(model.no);
//               onShowInfo(context, model);
//             },
//       onLongPress: () => onLongPress(model.no),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         width: w,
//         height: h,
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: borderColor, width: isSelected ? 3 : 1.8),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: _primary.withOpacity(0.18),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ]
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//         ),
//         child: Stack(
//           children: [
//             // Label + meta inside
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 6.0,
//                   vertical: 6,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       model.no,
//                       style: TextStyle(
//                         fontSize: premium ? 16 : 12,
//                         fontWeight: FontWeight.bold,
//                         color: isSelected ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       model.size,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: isSelected ? Colors.white70 : Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // if (isBooked)
//             //   Positioned(
//             //     top: 6,
//             //     right: 6,
//             //     child: Icon(Icons.lock, size: 16, color: Colors.red.shade700),
//             //   ),
//             // if (premium)
//             //   Positioned(
//             //     top: 6,
//             //     right: 0,
//             //     child: Icon,
//             //     // child: Container(
//             //     //   padding: const EdgeInsets.symmetric(
//             //     //     horizontal: 6,
//             //     //     vertical: 3,
//             //     //   ),
//             //     //   decoration: BoxDecoration(
//             //     //     color: Colors.amber.shade700,
//             //     //     borderRadius: BorderRadius.circular(6),
//             //     //   ),
//             //     //   child: const Text(
//             //     //     "PREMIUM",
//             //     //     style: TextStyle(
//             //     //       color: Colors.white,
//             //     //       fontSize: 6,
//             //     //       fontWeight: FontWeight.bold,
//             //     //     ),
//             //     //   ),
//             //     // ),
//             //   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_colors.dart';

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
  final Function(String plotNo, String size) onPlotSelected;

  const PlotSelectionWidget({super.key, required this.onPlotSelected});

  @override
  State<PlotSelectionWidget> createState() => _PlotSelectionWidgetState();
}

class _PlotSelectionWidgetState extends State<PlotSelectionWidget> {
  String? selectedPlot;
  OverlayEntry? _tooltipEntry;

  late final List<PlotModel> plots;

  @override
  void initState() {
    super.initState();

    /// MOVE YOUR PLOTS HERE
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

  PlotModel plotByNo(String no) => plots.firstWhere((p) => p.no == no);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLegend(),
        SizedBox(height: 10,),

        /// PLAN AREA AS WIDGET (NO SCREEN)
        _buildInteractivePlan(),

        // /// BUTTON FOR SELECTION (YOU CAN REMOVE IF NOT NEEDED)
        // SizedBox(
        //   width: double.infinity,
        //   height: 48,
        //   child: ElevatedButton(
        //     onPressed: selectedPlot == null
        //         ? null
        //         : () {
        //       final m = plotByNo(selectedPlot!);
        //       widget.onPlotSelected(m.no, m.size);
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: selectedPlot == null ? Colors.grey : _primary,
        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //     ),
        //     child: Text(
        //       selectedPlot == null
        //           ? "Select a plot"
        //           : "Confirm → Plot ${selectedPlot!}",
        //       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // -----------------------------
  // LEGEND
  // -----------------------------
  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(Icons.crop_square, Colors.green, "Available"),
        const SizedBox(width: 10),
        _legendItem(Icons.crop_square, Colors.red, "Sold"),
        const SizedBox(width: 10),
        _legendItem(Icons.crop_square, _primary, "Selected"),
        const SizedBox(width: 10),
        _legendItem(Icons.star, Colors.amber.shade700, "Premium"),
      ],
    );
  }

  Widget _legendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // -----------------------------
  // INTERACTIVE PLAN (GRID)
  // -----------------------------
  Widget _buildInteractivePlan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridSpacing = 10;
        final int columns = 5;
        final double cellWidth =
            (constraints.maxWidth - (columns - 1) * gridSpacing) / columns;

        return InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.7,
          maxScale: 2,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: columns,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            physics: const NeverScrollableScrollPhysics(),
            children: plots.map((p) {
              return _PlotBoxWidget(
                model: p,
                width: p.premium ? cellWidth * 0.8 : cellWidth,
                isSelected: selectedPlot == p.no,
                onTap: _handleTap,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handleTap(String plotNo) {
    final model = plotByNo(plotNo);

    if (model.booked) return;

    setState(() {
      selectedPlot = plotNo;
    });
  }
}

// -----------------------------
// PLOT BOX WIDGET
// -----------------------------
class _PlotBoxWidget extends StatelessWidget {
  final PlotModel model;
  final double width;
  final bool isSelected;
  final Function(String) onTap;

  const _PlotBoxWidget({
    super.key,
    required this.model,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool booked = model.booked;
    final bool premium = model.premium;
    return GestureDetector(
      onTap: booked ? null : () => onTap(model.no),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: width * 0.6,
        decoration: BoxDecoration(
          color: booked
              ? Colors.red.shade50
              : isSelected
              ? _primary
              : premium
              ? Colors.amber.shade50
              : Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: booked
                ? Colors.red
                : isSelected
                ? _primary
                : premium
                ? Colors.amber
                : Colors.green,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.no,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                model.size,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
