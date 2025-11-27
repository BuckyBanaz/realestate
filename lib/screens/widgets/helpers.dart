import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

const baseDur = Duration(milliseconds: 300);
const baseCurve = Curves.easeOutCubic;
Widget stagger(int i, Widget child) => child
    .animate(delay: (150 * i).ms)
    .fadeIn(duration: baseDur, curve: baseCurve)
    .slideY(begin: 0.15, end: 0, duration: baseDur, curve: baseCurve);