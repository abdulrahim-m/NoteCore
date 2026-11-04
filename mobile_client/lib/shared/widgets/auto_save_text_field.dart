import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_client/shared/utils/text_direction_utils.dart';

/// Borderless text field that saves itself: [onSave] is called ~0.6s after
/// typing stops, when focus is lost, and when the field is disposed.
///
/// Direction follows how the text starts. Empty text is never saved, on focus
/// loss it calls [onEmptyUnfocus] or, if null, restores the last saved text.
class AutoSaveTextField extends StatefulWidget {
  const AutoSaveTextField({
    super.key,
    required this.initialText,
    required this.onSave,
    this.onEmptyUnfocus,
    this.style,
    this.decoration,
  });

  final String initialText;
  final ValueChanged<String> onSave;
  final VoidCallback? onEmptyUnfocus;
  final TextStyle? style;
  final InputDecoration? decoration;

  @override
  State<AutoSaveTextField> createState() => _AutoSaveTextFieldState();
}

class _AutoSaveTextFieldState extends State<AutoSaveTextField> {
  late final TextEditingController _ctl = TextEditingController(
    text: widget.initialText,
  );
  final FocusNode _focus = FocusNode();
  late String _saved = widget.initialText.trim();
  late TextDirection? _dir = detectTextDirection(widget.initialText);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focus.hasFocus) return;
    _timer?.cancel();
    if (_ctl.text.trim().isEmpty) {
      if (widget.onEmptyUnfocus != null) {
        widget.onEmptyUnfocus!();
      } else {
        _ctl.text = _saved;
        _updateDir(_saved);
      }
    } else {
      _flush();
    }
  }

  void _updateDir(String text) {
    final dir = detectTextDirection(text);
    if (dir != _dir) setState(() => _dir = dir);
  }

  void _onChanged(String text) {
    _updateDir(text);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 600), _flush);
  }

  void _flush() {
    final text = _ctl.text.trim();
    if (text.isEmpty || text == _saved) return;
    _saved = text;
    widget.onSave(text);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flush(); // never lose the last edit
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctl,
      focusNode: _focus,
      style: widget.style,
      maxLines: null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      textDirection: _dir,
      onChanged: _onChanged,
      decoration: widget.decoration
    );
  }
}
