import 'package:flutter/material.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Contextual bar shown instead of search + groups while notes are selected.
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.count,
    required this.onClose,
    required this.onAddTag,
    required this.onChangeGroup,
    required this.onDelete,
  });

  final int count;
  final VoidCallback onClose;
  final VoidCallback onAddTag;
  final VoidCallback onChangeGroup;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: cs.primaryContainer.withValues(alpha: 0.4),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.notes_clear_selection,
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Text(
              l10n.notes_selected_count(count),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: l10n.notes_add_tag,
            onPressed: onAddTag,
            icon: const Icon(Icons.label_outline),
          ),
          IconButton(
            tooltip: l10n.notes_change_group,
            onPressed: onChangeGroup,
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            tooltip: l10n.notes_delete,
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: cs.error),
          ),
        ],
      ),
    );
  }
}
