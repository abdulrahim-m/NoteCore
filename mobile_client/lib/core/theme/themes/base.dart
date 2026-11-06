import 'package:flutter/painting.dart';

abstract class AppColors {
  // Brand (Shared)
  abstract final Color primary;
  abstract final Color primaryDark;
  abstract final Color secondary;

  // Light Palette
  abstract final Color lightBackground;
  abstract final Color lightSurface;
  abstract final Color lightTextPrimary;
  abstract final Color lightTextSecondary;
  abstract final Color lightTextMuted;
  abstract final Color lightBorder;

  // Dark Palette
  abstract final Color darkBackground;
  abstract final Color darkSurface;
  abstract final Color darkTextPrimary;
  abstract final Color darkTextSecondary;
  abstract final Color darkTextMuted;
  abstract final Color darkBorder;

  // Status Colors (Shared)
  abstract final Color error;
  abstract final Color success;
}