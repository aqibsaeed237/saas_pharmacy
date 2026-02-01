import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration
class AppTheme {
  // Light Theme Colors - neutral like other modern apps (no blue)
  static const Color lightPrimary = Color(0xFF374151);
  static const Color lightSecondary = Color(0xFF059669);
  static const Color lightError = Color(0xFFDC3545);
  static const Color lightWarning = Color(0xFFFFC107);
  static const Color lightSuccess = Color(0xFF28A745);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  // Dark Theme Colors - neutral like other modern apps (no blue)
  static const Color darkPrimary = Color(0xFF9CA3AF);
  static const Color darkSecondary = Color(0xFF34D399);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        error: lightError,
        surface: lightSurface,
        background: lightBackground,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnSecondary,
        onError: lightOnPrimary,
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        error: darkError,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
        onError: darkOnPrimary,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
      ),
    );
  }

  // Pharmacy Blue Theme (Vendor-specific)
  static ThemeData get pharmacyBlueLightTheme {
    return lightTheme.copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2), // Pharmacy blue
        secondary: Color(0xFF03A9F4),
        error: lightError,
        surface: lightSurface,
        background: lightBackground,
      ),
    );
  }

  static ThemeData get pharmacyBlueDarkTheme {
    return darkTheme.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF64B5F6), // Light pharmacy blue
        secondary: Color(0xFF4FC3F7),
        error: darkError,
        surface: darkSurface,
        background: darkBackground,
      ),
    );
  }

  // Medical Green Theme (Vendor-specific)
  static ThemeData get medicalGreenLightTheme {
    return lightTheme.copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF388E3C), // Medical green
        secondary: Color(0xFF66BB6A),
        error: lightError,
        surface: lightSurface,
        background: lightBackground,
      ),
    );
  }

  static ThemeData get medicalGreenDarkTheme {
    return darkTheme.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF81C784), // Light medical green
        secondary: Color(0xFFA5D6A7),
        error: darkError,
        surface: darkSurface,
        background: darkBackground,
      ),
    );
  }
}

