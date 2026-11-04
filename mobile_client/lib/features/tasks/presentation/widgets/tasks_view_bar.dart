import 'package:flutter/material.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class TasksViewBar extends StatelessWidget {
  const TasksViewBar({super.key, required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final c = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          SegmentedButton<TaskStatus>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(
                value: TaskStatus.unfinished,
                label: Text(l10n.tasks_status_unfinished),
              ),
              ButtonSegment(
                value: TaskStatus.finished,
                label: Text(l10n.tasks_status_finished),
              ),
            ],
            selected: {c.status},
            onSelectionChanged: (s) => c.setStatus(s.first),
          ),
          const Spacer(),
          PopupMenuButton<TaskKind>(
            initialValue: c.kind,
            onSelected: c.setKind,
            itemBuilder: (_) => [
              for (final k in TaskKind.values)
                PopupMenuItem(
                  value: k,
                  child: Row(
                    children: [
                      Icon(kindIcon(k), size: 20),
                      const SizedBox(width: 12),
                      Text(kindLabel(l10n, k)),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 6, 7),
              decoration: ShapeDecoration(
                shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
                color: c.kind == TaskKind.all ? null : cs.secondaryContainer,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(kindIcon(c.kind), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    kindLabel(l10n, c.kind),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
