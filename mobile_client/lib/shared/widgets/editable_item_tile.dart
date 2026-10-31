import 'package:flutter/material.dart';
import 'package:mobile_client/shared/widgets/auto_save_text_field.dart';

/// One editable line of a section: [leading] (bullet, checkbox, ...) + a text
/// field that saves itself. Swipe either way to delete; clearing the text
/// and leaving the field deletes too.
class EditableItemTile extends StatelessWidget {
  const EditableItemTile({
    super.key,
    required this.itemId,
    required this.leading,
    required this.text,
    required this.onSave,
    required this.onDelete,
    this.textStyle,
  });

  final int itemId;
  final Widget leading;
  final String text;
  final TextStyle? textStyle;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget swipeBackground(AlignmentGeometry alignment) => Container(
      color: cs.errorContainer,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
    );

    final style =
        textStyle ??
        (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: 16,
          height: 1.4,
          color: cs.onSurface,
        );

    return Dismissible(
      key: ValueKey(itemId),
      background: swipeBackground(AlignmentDirectional.centerStart),
      secondaryBackground: swipeBackground(AlignmentDirectional.centerEnd),
      onDismissed: (_) => onDelete(),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading,
                  Expanded(
                    child: AutoSaveTextField(
                      initialText: text,
                      style: style,
                      onSave: onSave,
                      onEmptyUnfocus: onDelete,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
