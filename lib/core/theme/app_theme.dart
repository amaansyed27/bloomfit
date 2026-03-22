import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryAction = Color(0xFFFF6B6B); // Vivid Coral
  static const Color secondaryAction = Color(0xFF4ECDC4); // Bright Teal
  static const Color accent = Color(0xFFFFE66D); // Sunny Yellow
  static const Color background = Color(0xFFFAFAFA); // Soft Off-White
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1D1D26); // Deep Charcoal
  static const Color textSecondary = Color(0xFF757575); // Soft Grey

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: primaryAction,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryAction,
      primary: primaryAction,
      secondary: secondaryAction,
      surface: surface,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0, // Flat design with border/shadow handled manually if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAction,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
