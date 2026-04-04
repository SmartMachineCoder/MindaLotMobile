import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood.dart';

class AppTheme {
  // Brand colours
  static const Color brandBrown = Color(0xFF5C3D2E);
  static const Color brandMint = Color(0xFFE8F4F4);
  static const Color brandCream = Color(0xFFFAF7F2);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textMedium = Color(0xFF7A6055);
  static const Color textLight = Color(0xFFB0A090);

  static ThemeData baseTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: brandBrown,
        secondary: Color(0xFF7DBF8E),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: brandMint,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w700, color: textDark),
        displayMedium: GoogleFonts.nunito(
          fontSize: 26, fontWeight: FontWeight.w700, color: textDark),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: textMedium),
        labelLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBrown,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: brandBrown, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(color: textLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
    );
  }

  /// Returns a theme adapted to the current mood
  static ThemeData moodTheme(MoodType mood) {
    final config = MoodData.get(mood);
    final base = baseTheme();
    return base.copyWith(
      scaffoldBackgroundColor: config.backgroundColor,
      colorScheme: base.colorScheme.copyWith(
        primary: config.primaryColor,
        surface: config.backgroundColor,
      ),
    );
  }
}
