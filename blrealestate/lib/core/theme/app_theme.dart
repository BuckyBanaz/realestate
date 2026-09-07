import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _createTheme(Brightness.light);
  static ThemeData get darkTheme => _createTheme(Brightness.dark);

  // Bundled Poppins — no network fetch, works offline
  static TextStyle _poppins({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: 'Poppins',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color surfaceColor    = isDark ? AppColors.surfaceDark    : AppColors.surfaceLight;
    final Color textPrimary     = isDark ? AppColors.textPrimaryDark   : AppColors.textPrimaryLight;
    final Color textSecondary   = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        displayLarge: _poppins(fontSize: 26, fontWeight: FontWeight.bold,  color: textPrimary),
        titleLarge:   _poppins(fontSize: 20, fontWeight: FontWeight.w600,  color: textPrimary),
        titleMedium:  _poppins(fontSize: 18, fontWeight: FontWeight.w600,  color: textPrimary),
        bodyLarge:    _poppins(fontSize: 18, color: textPrimary),
        bodyMedium:   _poppins(fontSize: 16, color: textSecondary),
        bodySmall:    _poppins(fontSize: 14, color: textSecondary),
        labelLarge:   _poppins(fontSize: 16, fontWeight: FontWeight.w600,  color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: _poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.surfaceLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceLight,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: _poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: _poppins(color: textSecondary),
        hintStyle: _poppins(color: textSecondary.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.snackBarBg,
        contentTextStyle: _poppins(color: AppColors.surfaceLight),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.surfaceLight.withValues(alpha: 0.12) : AppColors.textPrimaryLight.withValues(alpha: 0.12),
        thickness: 1,
      ),
    );
  }
}
