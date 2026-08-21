import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Listen with Eve — polished dark glass / violet conversation theme.
class AppTheme {
  static const Color background = Color(0xFF070817);
  static const Color background2 = Color(0xFF0D0B24);
  static const Color surface = Color(0xFF14152C);
  static const Color surfaceLight = Color(0xFF202047);
  static const Color primary = Color(0xFFB96BFF);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color accent = Color(0xFFE85DFF);
  static const Color success = Color(0xFF54E6A8);
  static const Color textPrimary = Color(0xFFF7F3FF);
  static const Color textSecondary = Color(0xFFAAA6BE);
  static const Color border = Color(0xFF3A3457);

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: border,
        error: Color(0xFFFF6B86),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF17162F).withOpacity(.92),
        hintStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: border.withOpacity(.55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: border.withOpacity(.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static List<BoxShadow> glow(
    Color color, {
    double blur = 18,
    double spread = 1,
    double opacity = .32,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }
}
