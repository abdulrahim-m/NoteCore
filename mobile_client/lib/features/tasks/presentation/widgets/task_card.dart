import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/utils/text_direction_utils.dart';
import 'package:mobile_client/shared/widgets/selectable_card.dart';
import 'package:mobile_client/shared/widgets/tag_pill.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.selected,
    required this.selecting,
    required this.expanded,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleDone,
    required this.onToggleExpanded,
    required this.onToggleSubTask,
  });

  final TaskDto task;
  final bool selected;
  final bool selecting;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleDone;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onToggleSubTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final t = task;
    final o = t.options;

    final title = t.title.trim().isEmpty ? l10n.notes_untitled : t.title.trim();
    final description = t.description.trim();
    final due = parseDue(o.dueDate);
    final overdue = isOverdue(t, DateTime.now());
    final tags = t.tags.take(4).toList();
    final extra = t.tags.length - tags.length;
    final subs = o.checkList ?? const <SubTaskDto>[];

    final details = <Widget>[
      if (o.priority != null)
        _Detail(
          Icons.flag,
          priorityLabel(l10n, o.priority!),
          color: priorityColor(cs, o.priority!),
        ),
      if (t.taskType == TaskTypeDto.periodic)
        _Detail(
          Icons.repeat,
          o.schedule == null
              ? l10n.tasks_type_periodic
              : scheduleLabel(context, o.schedule!),
        )
      else if (due != null)
        _Detail(
          Icons.event,
          whenLabel(context, due, withTime: dueHasTime(o.dueDate)),
          color: overdue ? cs.error : null,
        ),
      if (subs.isNotEmpty)
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: selecting ? null : onToggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Detail(
                  Icons.checklist,
                  '${subs.where((s) => s.checked).length}/${subs.length}',
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, size: 18, color: cs.outline),
                ),
              ],
            ),
          ),
        ),
    ];

    return SelectableCard(
      selected: selected,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selecting)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        14,
                        12,
                        12,
                        0,
                      ),
                      child: SelectionMark(selected: selected),
                    )
                  else
                    Checkbox(value: t.done, onChanged: (_) => onToggleDone()),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            textDirection: detectTextDirection(title),
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: t.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: t.done ? cs.outline : null,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: detectTextDirection(description),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: details,
                            ),
                          ],
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final tag in tags) TagPill(tag.name),
                                if (extra > 0) TagPill('+$extra'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (subs.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _SubTaskList(
                      subs: subs,
                      enabled: !selecting,
                      onToggle: onToggleSubTask,
                    )
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }
}

class _SubTaskList extends StatelessWidget {
  const _SubTaskList({
    required this.subs,
    required this.enabled,
    required this.onToggle,
  });

  final List<SubTaskDto> subs;
  final bool enabled;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < subs.length; i++)
            InkWell(
              onTap: enabled ? () => onToggle(i) : null,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, end: 14),
                child: Row(
                  children: [
                    Checkbox(
                      value: subs[i].checked,
                      visualDensity: VisualDensity.compact,
                      onChanged: enabled ? (_) => onToggle(i) : null,
                    ),
                    Expanded(
                      child: Text(
                        subs[i].text,
                        textDirection: detectTextDirection(subs[i].text),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: subs[i].checked
                              ? TextDecoration.lineThrough
                              : null,
                          color: subs[i].checked ? cs.outline : null,
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

class _Detail extends StatelessWidget {
  const _Detail(this.icon, this.text, {this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: c),
          ),
        ),
      ],
    );
  }
}
