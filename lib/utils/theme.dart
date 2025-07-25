// lib/utils/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // MopTaste Color Palette
  static const Color primaryOrange = Color(0xFFFFA726); // A vibrant orange
  static const Color primaryYellow = Color(0xFFFFC107); // A bright yellow for accents
  static const Color accentRed = Color(0xFFEF5350);    // A reddish accent for warnings/errors
  static const Color neutralBlack = Color(0xFF212121); // For primary text
  static const Color darkGrey = Color(0xFF757575);     // For secondary text and icons
  static const Color lightGrey = Color(0xFFE0E0E0);    // For borders and backgrounds
  static const Color neutralWhite = Color(0xFFFFFFFF); // For backgrounds and text on dark elements

  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(
      primaryOrange.value,
      const <int, Color>{
        50: Color(0xFFFFF3E0),
        100: Color(0xFFFFE0B2),
        200: Color(0xFFFFCC80),
        300: Color(0xFFFFB74D),
        400: Color(0xFFFFA726),
        500: Color(0xFFFF9800),
        600: Color(0xFFFB8C00),
        700: Color(0xFFF57C00),
        800: Color(0xFFEF6C00),
        900: Color(0xFFE65100),
      },
    ),
    scaffoldBackgroundColor: neutralWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: neutralWhite,
      elevation: 4,
      iconTheme: IconThemeData(color: neutralWhite),
      titleTextStyle: TextStyle(
        color: neutralWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: neutralWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryOrange,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: lightGrey, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentRed, width: 2),
      ),
      labelStyle: TextStyle(color: darkGrey),
      hintStyle: TextStyle(color: darkGrey.withOpacity(0.6)),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: neutralWhite,
    ),
    // Define text themes
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: neutralBlack),
      headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: neutralBlack),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: neutralBlack),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: neutralBlack),
      titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: neutralBlack),
      titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: neutralBlack),
      bodyLarge: TextStyle(fontSize: 16.0, color: neutralBlack),
      bodyMedium: TextStyle(fontSize: 14.0, color: neutralBlack),
      bodySmall: TextStyle(fontSize: 12.0, color: darkGrey),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: neutralWhite),
      labelMedium: TextStyle(fontSize: 12.0, color: darkGrey),
      labelSmall: TextStyle(fontSize: 10.0, color: darkGrey),
    ),
  );
}