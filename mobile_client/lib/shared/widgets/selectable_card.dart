import 'package:flutter/material.dart';

/// Card that shows a primary outline + tint when [selected].
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.child,
    this.margin,
  });

  final bool selected;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      color: selected ? cs.primaryContainer.withValues(alpha: 0.35) : null,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: cs.primary, width: 2),
            )
          : null,
      child: child,
    );
  }
}

/// Check circle shown on cards while selecting.
class SelectionMark extends StatelessWidget {
  const SelectionMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Icon(
      selected ? Icons.check_circle : Icons.circle_outlined,
      size: 22,
      color: selected ? cs.primary : cs.outline,
    );
  }
}
