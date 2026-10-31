
import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';
import 'package:mobile_client/core/theme/themes/rust.dart';

class ThemeProvider extends ChangeNotifier {
  AppColors _currentTheme = RustThemeColors();

  AppColors get currentTheme => _currentTheme;

  void setTheme(AppColors newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
}