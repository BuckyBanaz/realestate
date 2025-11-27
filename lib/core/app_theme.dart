import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,

    // 👇 Calibri alternative font (Carlito)
    textTheme: GoogleFonts.carlitoTextTheme() ,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      primary: primary,
      secondary: secondary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white
        ),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(size: 22),
      titleTextStyle: GoogleFonts.carlito(
        color: Colors.black,
        fontSize: 20,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 3.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: secondary),
    ),
  );
}
