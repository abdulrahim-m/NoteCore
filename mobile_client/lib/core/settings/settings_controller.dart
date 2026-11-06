import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/theme/themes/base.dart';
import 'package:mobile_client/core/theme/themes/theme_registry.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';

class SettingsController extends ChangeNotifier with ApiGuard {
  SettingsController(this._core);

  final NoteCore _core;
  Map<String, String> _raw = {};
  bool _disposed = false;

  Future<void> load() async {
    final ok = await guard(() async => _raw = await _core.getSettings());
    if (ok) notifyListeners();
  }

  T get<T>(Setting<T> s) => s.read(_raw);

  Future<void> set<T>(Setting<T> s, T value) async {
    final encoded = s.encode(s.clean(value));
    if (_raw[s.key] == encoded) return;
    final previous = _raw;
    _raw = {..._raw, s.key: encoded};
    notifyListeners();
    final ok = await guard(
      () => _core.setSetting(key: s.key, value: encoded),
    );
    if (!ok) {
      _raw = previous;
      notifyListeners();
    }
  }

  Future<void> resetAll() async {
    if (await guard(_core.resetSettings)) await load();
  }

  // ------------------------------------------------------ typed shortcuts
  String get language => get(AppSettings.language);
  int get resetHour => get(AppSettings.resetHour);
  int get fontSize => get(AppSettings.fontSize);

  Locale? get locale {
    final l = language;
    return l == 'default' ? null : Locale(l);
  }

  AppThemeOption get themeOption => themeById(get(AppSettings.theme));
  AppColors get themeColors => themeOption.colors;

  double get textScale => fontSize / AppSettings.fontSizeDesign;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
