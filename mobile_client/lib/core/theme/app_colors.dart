import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand (Shared)
  static const Color primary = Color.fromRGBO(230, 112, 34, 1);
  static const Color primaryDark = Color.fromRGBO(190, 90, 24, 1);
  static const Color secondary = Color.fromARGB(255, 42, 27, 15);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color.fromARGB(255, 42, 27, 15);
  static const Color lightTextSecondary = Color.fromARGB(255, 139, 117, 100);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Palette
  static const Color darkBackground = Color.fromARGB(255, 42, 25, 15);
  static const Color darkSurface = Color.fromARGB(255, 50, 29, 17);
  static const Color darkTextPrimary = Color.fromARGB(255, 252, 250, 248);
  static const Color darkTextSecondary = Color.fromARGB(255, 184, 165, 148);
  static const Color darkTextMuted = Color.fromARGB(255, 139, 120, 100);
  static const Color darkBorder = Color.fromARGB(255, 85, 65, 51);

  // Status Colors (Shared)
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
}
