import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/widgets/tags_drawer.dart';

class TaskFiltersPanel extends StatelessWidget {
  const TaskFiltersPanel({super.key, required this.controller});

  final TasksController controller;

  Future<void> _pickDate(BuildContext context, {required bool after}) async {
    final c = controller;
    final current = after ? c.dueAfter : c.dueBefore;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    if (after) {
      c.setDueAfter(DateTime(picked.year, picked.month, picked.day));
    } else {
      c.setDueBefore(
        DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = MaterialLocalizations.of(context);
    final c = controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tasks_priority, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final p in PriorityDto.values)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(priorityLabel(l10n, p)),
                selected: c.priority == p,
                onSelected: (on) => c.setPriority(on ? p : null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilterDateTile(
          label: l10n.tasks_due_after,
          value: c.dueAfter == null ? null : loc.formatShortDate(c.dueAfter!),
          onTap: () => _pickDate(context, after: true),
          onClear: () => c.setDueAfter(null),
        ),
        const SizedBox(height: 8),
        FilterDateTile(
          label: l10n.tasks_due_before,
          value: c.dueBefore == null ? null : loc.formatShortDate(c.dueBefore!),
          onTap: () => _pickDate(context, after: false),
          onClear: () => c.setDueBefore(null),
        ),
      ],
    );
  }
}
