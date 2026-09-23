import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF302C9E);
  static const Color seararRed = Color(0xFFE30613);
  static const Color white = Color(0xFFFFFFFF);
  static const Color borderGrey = Color(0xFFD9D9D9);
  static const Color textGrey = Color(0xFF8D8C8C);
  static const Color textDark = Color(0xFF101038);

  static TextTheme get _textTheme =>
      GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);

  static ThemeData get theme {
    final textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: seararRed),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textGrey),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle: textTheme.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
