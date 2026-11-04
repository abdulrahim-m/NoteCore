import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/short_task.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/widgets/selectable_card.dart';
import 'package:mobile_client/shared/widgets/tag_pill.dart';
import 'package:mobile_client/shared/utils/text_direction_utils.dart';

/// A checklist as an expandable card: tap the header to open/close it, tick
/// tasks right in the list, tap the pencil to edit the checklist itself.
class ChecklistCard extends StatelessWidget {
  const ChecklistCard({
    super.key,
    required this.section,
    required this.items,
    required this.expanded,
    required this.selected,
    required this.selecting,
    required this.onHeaderTap,
    required this.onLongPress,
    required this.onOpen,
    required this.onToggleItem,
  });

  final ShortTaskSectionDto section;

  /// The tasks to list (already filtered by the controller).
  final List<ShortTaskItemDto> items;
  final bool expanded;
  final bool selected;
  final bool selecting;
  final VoidCallback onHeaderTap;
  final VoidCallback onLongPress;
  final VoidCallback onOpen;
  final ValueChanged<int> onToggleItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final title = section.title.trim().isEmpty
        ? l10n.notes_untitled
        : section.title.trim();
    final total = section.items.length;
    final done = section.items.where((i) => i.done).length;
    final shown = section.tags.take(3).toList();
    final extra = section.tags.length - shown.length;

    return SelectableCard(
      selected: selected,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onHeaderTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 6, 10),
              child: Row(
                children: [
                  if (selecting)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: SelectionMark(selected: selected),
                    ),
                  Expanded(
                    child: Column(
                      // stretch: the title aligns by its own direction
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textDirection: detectTextDirection(title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (shown.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final t in shown) TagPill(t.name),
                              if (extra > 0) TagPill('+$extra'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text('$done/$total', style: theme.textTheme.labelMedium),
                  if (!selecting)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.checklists_edit_tasks,
                      onPressed: onOpen,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: cs.outline),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          LinearProgressIndicator(
            minHeight: 3,
            value: total == 0 ? 0 : done / total,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? _body(context, l10n)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.checklists_no_tasks,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final item in items)
            InkWell(
              key: ValueKey(item.id),
              onTap: selecting ? null : () => onToggleItem(item.id),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Row(
                  children: [
                    Checkbox(
                      value: item.done,
                      onChanged: selecting ? null : (_) => onToggleItem(item.id),
                    ),
                    Expanded(
                      child: Text(
                        item.text,
                        textDirection: detectTextDirection(item.text),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.done ? cs.outline : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
