import 'package:flutter/widgets.dart';

final RegExp _letter = RegExp(r'\p{L}', unicode: true);

/// Direction of [text] from its first strongly-directional character.
///
/// Digits, punctuation, spaces and the editor's own list/heading markers
/// (`☐ • #` ...) are neutral and skipped. Returns null when there is no strong
/// character yet, so callers can fall back to the app's direction.
TextDirection? detectTextDirection(String text) {
  for (final r in text.runes) {
    if (r == 0x200F) return TextDirection.rtl; // RLM
    if (r == 0x200E) return TextDirection.ltr; // LRM
    if (_isStrongRtl(r)) return TextDirection.rtl;
    if (_letter.hasMatch(String.fromCharCode(r))) return TextDirection.ltr;
  }
  return null;
}

bool _isStrongRtl(int r) {
  if (r >= 0x0590 && r <= 0x08FF) {
    if (r >= 0x0660 && r <= 0x0669) return false; // Arabic-Indic digits
    if (r >= 0x06F0 && r <= 0x06F9) return false; // extended digits
    if (r == 0x060C || r == 0x06DD || r == 0x08E2) return false;
    if (r >= 0x0600 && r <= 0x0605) return false; // number signs
    return true;
  }
  if (r >= 0xFB1D && r <= 0xFB4F) return true; // Hebrew presentation forms
  if (r >= 0xFB50 && r <= 0xFDFF) {
    return r != 0xFD3E && r != 0xFD3F; // ornate parentheses are neutral
  }
  if (r >= 0xFE70 && r <= 0xFEFE) return true; // Arabic presentation forms B
  if (r >= 0x10800 && r <= 0x10FFF) return true; // historic RTL scripts
  if (r >= 0x1E800 && r <= 0x1EFFF) return true; // Adlam, Arabic math, ...
  return false;
}
