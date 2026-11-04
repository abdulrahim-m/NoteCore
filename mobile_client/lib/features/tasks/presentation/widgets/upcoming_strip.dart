import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/utils/text_direction_utils.dart';

class UpcomingStrip extends StatelessWidget {
  const UpcomingStrip({
    super.key,
    required this.entries,
    required this.onOpen,
    required this.onToggle,
  });

  final List<UpcomingEntry> entries;
  final ValueChanged<int> onOpen;
  final ValueChanged<int> onToggle;

  static const double _cardHeight = 78;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height / 3;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Text(
              l10n.tasks_upcoming,
              style: theme.textTheme.titleSmall,
            ),
          ),
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _UpcomingCard(
                entry: entries[i],
                onOpen: () => onOpen(entries[i].task.id),
                onToggle: () => onToggle(entries[i].task.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.entry,
    required this.onOpen,
    required this.onToggle,
  });

  final UpcomingEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = entry.task;
    final periodic = t.taskType == TaskTypeDto.periodic;
    final overdue = isOverdue(t, DateTime.now());
    final color = overdue ? cs.error : cs.onSurfaceVariant;
    final title = t.title.trim().isEmpty
        ? AppLocalizations.of(context)!.notes_untitled
        : t.title.trim();

    return SizedBox(
      width: 200,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Row(
            children: [
              Checkbox(
                value: t.done,
                onChanged: (_) => onToggle(),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: detectTextDirection(title),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          periodic ? Icons.repeat : Icons.event,
                          size: 13,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            whenLabel(
                              context,
                              entry.when,
                              withTime: periodic || dueHasTime(t.options.dueDate),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
