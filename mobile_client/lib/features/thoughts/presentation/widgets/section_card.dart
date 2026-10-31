import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/short_note.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/tag_pill.dart';
import 'package:mobile_client/shared/text_direction_utils.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.selected,
    required this.selecting,
    required this.compact,
    required this.onTap,
    required this.onLongPress,
  });

  static const double gridExtent = 140;

  final ShortNoteSectionListItemDto section;
  final bool selected;
  final bool selecting;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final name = section.name.trim().isEmpty
        ? l10n.notes_untitled
        : section.name.trim();
    final shown = section.tags.take(compact ? 2 : 4).toList();
    final extra = section.tags.length - shown.length;

    return Card(
      margin: compact ? const EdgeInsets.all(4) : null,
      clipBehavior: Clip.antiAlias,
      color: selected ? cs.primaryContainer.withValues(alpha: 0.35) : null,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: cs.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selecting)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10, top: 2),
                  child: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    size: 22,
                    color: selected ? cs.primary : cs.outline,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      name,
                      textDirection: detectTextDirection(name),
                      maxLines: compact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.thoughts_count(section.listedItems),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (shown.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
