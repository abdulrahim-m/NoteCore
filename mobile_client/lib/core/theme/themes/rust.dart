import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class RustThemeColors implements AppColors {
  // Brand (Shared)
  @override final Color primary = Color.fromRGBO(230, 112, 34, 1);
  @override final Color primaryDark = Color.fromRGBO(190, 90, 24, 1);
  @override final Color secondary = Color.fromARGB(255, 42, 27, 15);

  // Light Palette
  @override final Color lightBackground = Color(0xFFF8FAFC);
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 42, 27, 15);
  @override final Color lightTextSecondary = Color.fromARGB(255, 139, 117, 100);
  @override final Color lightTextMuted = Color(0xFF94A3B8);
  @override final Color lightBorder = Color(0xFFE2E8F0);

  // Dark Palette
  @override final Color darkBackground = Colors.black;
  @override final Color darkSurface = Color.fromARGB(255, 10, 7, 3);
  @override final Color darkTextPrimary = Color.fromARGB(255, 252, 250, 248);
  @override final Color darkTextSecondary = Color.fromARGB(255, 184, 165, 148);
  @override final Color darkTextMuted = Color.fromARGB(255, 139, 120, 100);
  @override final Color darkBorder = Color.fromARGB(255, 85, 65, 51);

  // Status Colors (Shared)
  @override final Color error = Color(0xFFEF4444);
  @override final Color success = Color(0xFF22C55E);
}