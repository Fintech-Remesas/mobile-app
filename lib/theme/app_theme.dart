import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF3266C7);
  static const Color accentGreen = Color(0xFF86EB84);
  static const Color secondaryBlue = Color(0xFF59A2D8);

  static const Color bgMain = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF4F7FA);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color borderColor = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgMain,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentGreen,
        surface: surfaceLight,
        error: Colors.red,
      ),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          color: primaryBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
        displayMedium: base.displayMedium?.copyWith(
          color: textDark,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: base.titleLarge?.copyWith(
          color: primaryBlue,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: base.titleMedium?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.bodyLarge?.copyWith(color: textDark),
        bodyMedium: base.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: base.bodySmall?.copyWith(color: textSecondary),
        labelLarge: base.labelLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: base.labelMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgMain,
        foregroundColor: primaryBlue,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryBlue,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: textDark,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shadowColor: accentGreen.withOpacity(0.4),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgMain,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgMain,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: textSecondary),
      ),
      cardTheme: CardTheme(
        color: bgMain,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }

  static const Color darkBgMain = Color(0xFF1A202C);
  static const Color darkSurfaceLight = Color(0xFF2D3748);
  static const Color darkTextLight = Color(0xFFF7FAFC);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);
  static const Color darkBorderColor = Color(0xFF4A5568);

  static ThemeData get darkTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentGreen,
      scaffoldBackgroundColor: darkBgMain,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: primaryBlue,
        surface: darkSurfaceLight,
        error: Colors.redAccent,
      ),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
        displayMedium: base.displayMedium?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: base.titleLarge?.copyWith(
          color: accentGreen,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: base.titleMedium?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.bodyLarge?.copyWith(color: darkTextLight),
        bodyMedium: base.bodyMedium?.copyWith(color: darkTextSecondary),
        bodySmall: base.bodySmall?.copyWith(color: darkTextSecondary),
        labelLarge: base.labelLarge?.copyWith(
          color: darkTextLight,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: base.labelMedium?.copyWith(
          color: darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBgMain,
        foregroundColor: darkTextLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: darkBgMain,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shadowColor: accentGreen.withOpacity(0.4),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGreen,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBgMain,
        selectedItemColor: accentGreen,
        unselectedItemColor: darkTextSecondary,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGreen, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: darkTextSecondary),
      ),
      cardTheme: CardTheme(
        color: darkSurfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor),
        ),
      ),
    );
  }
}
