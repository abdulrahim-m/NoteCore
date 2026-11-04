import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Tag chips with an "add tag" chip; tap a chip to edit, x to remove.
class TagChipsRow extends StatelessWidget {
  const TagChipsRow({
    super.key,
    required this.tags,
    required this.onEdit,
    required this.onRemove,
  });

  final List<TagDto> tags;
  final VoidCallback onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tag in tags)
          InputChip(
            visualDensity: VisualDensity.compact,
            label: Text(tag.name),
            onPressed: onEdit,
            onDeleted: () => onRemove(tag.id),
          ),
        ActionChip(
          visualDensity: VisualDensity.compact,
          avatar: const Icon(Icons.add, size: 18),
          label: Text(l10n.notes_add_tag),
          onPressed: onEdit,
        ),
      ],
    );
  }
}
