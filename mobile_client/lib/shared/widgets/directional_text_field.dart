import 'package:flutter/material.dart';
import 'package:mobile_client/shared/utils/text_direction_utils.dart';

class DirectionalTextField extends StatelessWidget {
  const DirectionalTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        textDirection: detectTextDirection(value.text),
        decoration: decoration,
        style: style,
        minLines: minLines,
        maxLines: maxLines,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
