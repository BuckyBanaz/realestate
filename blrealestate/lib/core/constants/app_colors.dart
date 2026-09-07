import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary      = Color(0xFF6B9935);
  static const Color primaryLight = Color(0xFF99C762);
  static const Color secondary    = Color(0xFFCFB53B); // Gold
  static const Color transparent  = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight    = Colors.white;
  static const Color backgroundDark  = Color(0xFF000000);
  static const Color surfaceDark     = Color(0xFF111111);

  // Text
  static const Color textPrimaryLight   = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark    = Color(0xFFF1F5F9);
  static const Color textSecondaryDark  = Color(0xFF94A3B8);

  // Input fill
  static const Color inputFillDark  = Color(0xFF1E293B);
  static const Color inputFillLight = Color(0xFFF1F5F9);

  // Snackbar
  static const Color snackBarBg = Color(0xFF1E293B);

  // Status
  static const Color success    = Color(0xFF10B981);
  static const Color error      = Color(0xFFEF4444);
  static const Color pending    = Color(0xFFF59E0B);
  static const Color info       = Color(0xFF3B82F6);
  static const Color priceGreen = Color(0xFF81C784);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'available':
      case 'active':
      case 'won':
      case 'approved':
      case 'closed':
        return success;
      case 'pending':
      case 'in_progress':
      case 'booked':
      case 'follow_up':
      case 'hold':
      case 'negotiation':
        return pending;
      case 'cancelled':
      case 'lost':
      case 'rejected':
      case 'sold':
        return error;
      default:
        return Colors.blueGrey;
    }
  }

  // Shimmer / skeleton
  static const Color shimmerBaseDark  = Color(0xFF1E293B);
  static const Color shimmerBaseLight = Color(0xFFF1F5F9);
  static const Color skeletonBaseDark = Color(0xFF334155);
  static const Color skeletonHighDark = Color(0xFF475569);

  // Stat card gradients
  static const List<Color> statBlue   = [Color(0xFF64B5F6), Color(0xFF1976D2)];
  static const List<Color> statOrange = [Color(0xFFFFB74D), Color(0xFFF57C00)];
  static const List<Color> statGreen  = [Color(0xFF81C784), Color(0xFF388E3C)];
  static const List<Color> statPurple = [Color(0xFFBA68C8), Color(0xFF7B1FA2)];

  // Quick action backgrounds (light mode)
  static const Color actionBgBlue   = Color(0xFFEFF6FF);
  static const Color actionBgGreen  = Color(0xFFF0FDF4);
  static const Color actionBgOrange = Color(0xFFFFF7ED);
  static const Color actionBgPurple = Color(0xFFFDF4FF);

  // Quick action icon colors
  static const Color actionIconBlue   = Color(0xFF3B82F6);
  static const Color actionIconGreen  = Color(0xFF22C55E);
  static const Color actionIconOrange = Color(0xFFF97316);
  static const Color actionIconPurple = Color(0xFF9333EA);

  // Lead status colors
  static const Color statusNegotiation = Color(0xFFF97316);
  static const Color statusProposal    = Color(0xFF3B82F6);
  static const Color statusContacted   = Color(0xFF14B8A6);
  static const Color statusSeen        = Color(0xFF6366F1);

  // Notification type colors
  static const Color notifLead  = Color(0xFF3B82F6);
  static const Color notifTask  = Color(0xFFF97316);
  static const Color notifDeal  = Color(0xFF9333EA);

  // Plot status colors
  static const Color plotActive = Color(0xFF4CAF50);
  static const Color plotHold   = Color(0xFFFF9800);
  static const Color plotSold   = Color(0xFFF44336);

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Theme-aware helpers ──────────────────────────────────────────────────

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  static Color inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? inputFillDark
          : inputFillLight;

  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.transparent
          : const Color(0xFFE2E8F0);

  static List<BoxShadow> cardShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? []
          : [
              BoxShadow(
                color: AppColors.textPrimary(context).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ];

  static Color shimmerBase(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? shimmerBaseDark
          : shimmerBaseLight;
}
