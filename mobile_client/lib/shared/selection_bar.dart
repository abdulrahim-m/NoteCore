import 'package:flutter/material.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// A flexible contextual selection bar that accepts arbitrary action widgets.
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.count,
    required this.onClose,
    required this.actions,
  });

  final int count;
  final VoidCallback onClose;
  final List<Widget> actions;

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
          ...actions,
        ],
      ),
    );
  }
}