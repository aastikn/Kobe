import 'package:flutter/material.dart';

class AppTheme {
  // Color scheme using purple, yellow, white, and brown
  static const Color primaryPurple = Color(0xFF6A1B9A); // Deep Purple
  static const Color accentYellow = Color(0xFFFBC02D); // Yellow
  static const Color backgroundWhite = Color(0xFFF5F5F5); // Almost White
  static const Color textBrown = Color(0xFF5D4037); // Brown

  // Light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryPurple,
    primarySwatch: Colors.purple,
    scaffoldBackgroundColor: backgroundWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryPurple,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentYellow,
      foregroundColor: textBrown,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: textBrown,
      iconColor: primaryPurple,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textBrown),
      bodyMedium: TextStyle(color: textBrown),
      titleLarge: TextStyle(color: textBrown, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
    ).copyWith(
      secondary: accentYellow,
      background: backgroundWhite,
    ),
  );
}
