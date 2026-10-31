import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

import 'app_text_styles.dart';

class AppTheme {
  // ==================== LIGHT THEME ====================
  static ThemeData getLightTheme(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.lightBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.lightSurface,
        error: colors.error,
        onSurface: colors.lightTextPrimary,
      ),

      textTheme: TextTheme(
        headlineMedium: AppTextStyles.display.copyWith(
          color: colors.lightTextPrimary,
        ),
        titleMedium: AppTextStyles.title.copyWith(
          color: colors.lightTextPrimary,
        ),
        bodyMedium: AppTextStyles.body.copyWith(
          color: colors.lightTextSecondary,
        ),
        bodySmall: AppTextStyles.caption.copyWith(
          color: colors.lightTextMuted,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.lightSurface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colors.lightBorder, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.lightSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: colors.lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: colors.lightTextPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.lightSurface,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData getDarkTheme(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.dark,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.darkSurface,
        error: colors.error,
        onSurface: colors.darkTextPrimary,
      ),

      textTheme: TextTheme(
        headlineMedium: AppTextStyles.display.copyWith(
          color: colors.darkTextPrimary,
        ),
        titleMedium: AppTextStyles.title.copyWith(
          color: colors.darkTextPrimary,
        ),
        bodyMedium: AppTextStyles.body.copyWith(
          color: colors.darkTextSecondary,
        ),
        bodySmall: AppTextStyles.caption.copyWith(
          color: colors.darkTextMuted,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.darkSurface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colors.darkBorder, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.darkSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: colors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: colors.darkTextPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.darkSurface,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }
}
