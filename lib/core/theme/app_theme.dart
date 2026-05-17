import 'package:flutter/material.dart';

/// Centralized colors and text styles for AudioMood.
/// Matches the dark wireframes with the purple/magenta accent from the logo.
class AppColors {
  static const Color background = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color card = Color(0xFFEDEDED);
  static const Color primary = Color(0xFF9C27B0);
  static const Color primaryDark = Color(0xFF6A1B9A);
  static const Color accent = Color(0xFFE91E63);
  static const Color textOnDark = Colors.white;
  static const Color textOnLight = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFFB0B0B0);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textOnDark),
          titleTextStyle: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textOnLight,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.grey,
          suffixIconColor: Colors.grey,
        ),
      );
}
