import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/guide/guide_target.dart';
import 'package:mobile_client/core/rust/api/tasks.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_card.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_filters_panel.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/tasks_view_bar.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/upcoming_strip.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/views/searchable_list_page.dart';
import 'package:mobile_client/shared/widgets/section_selection_actions.dart';

/// "Tasks" tab: search, one slim row to pick unfinished/finished and the kind
/// of tasks, and the list. The default view (all + unfinished) starts with a
/// compact upcoming strip. Task-only filters live in the filter drawer.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SearchableListPage<TasksController, TaskDto>(
      create: (filters) =>
          TasksController(api: getIt<TasksApi>(), filters: filters),
      // id < 0 = a new task
      routeOf: (id) => id < 0 ? '/tasks/new' : '/tasks/$id',
      onCreate: (context, c, open) => open(-1),
      createTooltip: l10n.tasks_new,
      visibleCount: (c) => c.shown.length,
      emptyText: (c) {
        if (c.status == TaskStatus.finished) return l10n.tasks_empty_finished;
        return switch (c.kind) {
          TaskKind.all => l10n.tasks_empty,
          TaskKind.oneTime => l10n.tasks_empty_simple,
          TaskKind.periodic => l10n.tasks_empty_periodic,
        };
      },
      emptyIcon: Icons.task_alt,
      searchHint: l10n.tasks_search_hint,
      selectionActions: (context, c) => buildSelectionActions<TaskDto>(
        context,
        controller: c,
        deleteTitle: l10n.tasks_delete_title,
        deleteBody: l10n.tasks_delete_body,
      ),
      toolbar: (context, c) => TasksViewBar(controller: c),
      customFilters: (context, c) => TaskFiltersPanel(controller: c),
      slivers: (context, c, open) {
        final tasks = c.shown;
        return [
          if (c.showsUpcoming) ...[
            SliverToBoxAdapter(
              child: GuideTarget(
                id: 'upcoming',
                child: UpcomingStrip(
                  entries: c.upcoming,
                  onOpen: open,
                  onToggle: c.toggleDone,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.tasks_status_unfinished,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            sliver: SliverList.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final t = tasks[i];
                final card = TaskCard(
                  key: ValueKey(t.id),
                  task: t,
                  selecting: c.selecting,
                  selected: c.selectedIds.contains(t.id),
                  onLongPress: () => c.toggleSelection(t.id),
                  onTap: () => c.selecting ? c.toggleSelection(t.id) : open(t.id),
                  onToggleDone: () => c.toggleDone(t.id),
                  expanded: c.isExpanded(t.id),
                  onToggleExpanded: () => c.toggleExpanded(t.id),
                  onToggleSubTask: (i) => c.toggleSubTask(t.id, i),
                );
                return i == 0
                    ? GuideTarget(
                        key: ValueKey('guide-${t.id}'),
                        id: 'item',
                        child: card,
                      )
                    : card;
              },
            ),
          ),
        ];
      },
    );
  }
}
