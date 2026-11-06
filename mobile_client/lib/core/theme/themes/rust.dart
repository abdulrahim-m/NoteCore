import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class RustThemeColors implements AppColors {
  // Brand (Shared)
  @override final Color primary = Color.fromRGBO(194, 84, 41, 1); // rich Rust
  @override final Color primaryDark = Color.fromRGBO(150, 60, 25, 1); // Deep burnt rust
  @override final Color secondary = Color.fromARGB(255, 100, 61, 42); // Warm espresso brown

  // Light Palette
  @override final Color lightBackground = Color(0xFFFCFBFA); // Clean warm ivory
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 44, 31, 24); // Rich warm dark brown-charcoal
  @override final Color lightTextSecondary = Color.fromARGB(255, 115, 95, 84); // Warm taupe/bronze
  @override final Color lightTextMuted = Color(0xFFA69688);
  @override final Color lightBorder = Color(0xFFE8E1D9);

  // Dark Palette (Updated for high-contrast tags, badges, and surfaces)
  @override final Color darkBackground = Color(0xFF100C0A); // Richer, deeper espresso dark
  @override final Color darkSurface = Color.fromARGB(255, 30, 24, 20); // Lifted surface color for clear card/badge distinction
  @override final Color darkTextPrimary = Color.fromARGB(255, 250, 247, 242); // Crisp near-white for high legibility
  @override final Color darkTextSecondary = Color.fromARGB(255, 205, 190, 180); // Brighter taupe for secondary text/icons
  @override final Color darkTextMuted = Color.fromARGB(255, 150, 135, 125); // Clear, readable muted text
  @override final Color darkBorder = Color.fromARGB(255, 70, 56, 47); // Defined border/badge outline for high contrast

  // Status Colors (Shared)
  @override final Color error = Color(0xFFEF4444);
  @override final Color success = Color(0xFF22C55E);
}