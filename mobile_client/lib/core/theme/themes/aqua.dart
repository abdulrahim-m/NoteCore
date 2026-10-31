import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class AquaThemeColors implements AppColors {
  // Brand (Shared)
  @override final Color primary = Color.fromRGBO(115, 198, 242, 1); // Baby Blue
  @override final Color primaryDark = Color.fromRGBO(74, 161, 206, 1);
  @override final Color secondary = Color.fromARGB(255, 120, 140, 180);

  // Light Palette
  @override final Color lightBackground = Color(0xFFF4F8FA);
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 30, 45, 60);
  @override final Color lightTextSecondary = Color.fromARGB(255, 90, 110, 130);
  @override final Color lightTextMuted = Color(0xFFB0C2CD);
  @override final Color lightBorder = Color(0xFFD4E3EE);

  // Dark Palette
  @override final Color darkBackground = Color(0xFF121820);
  @override final Color darkSurface = Color.fromARGB(255, 20, 28, 38);
  @override final Color darkTextPrimary = Color.fromARGB(255, 235, 242, 250);
  @override final Color darkTextSecondary = Color.fromARGB(255, 160, 175, 195);
  @override final Color darkTextMuted = Color.fromARGB(255, 110, 125, 145);
  @override final Color darkBorder = Color.fromARGB(255, 35, 48, 64);

  // Status Colors (Shared)
  @override final Color error = Color(0xFFE57373);
  @override final Color success = Color(0xFF81C784);
}